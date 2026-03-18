//+------------------------------------------------------------------+
//|                                                  LA_Backtest.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Guy Jasper Gonzaga"
#property link "https://www.mql5.com"
#property version "1.00"

// Define the struct - must match C# layout exactly
struct GenericEvent
{
   int CommandID;
   long LongValue;
   double DoubleValue;
   uchar StringValue[128]; // 64 U nicode chars = 128 bytes
};

// #import "MQLBridge.dll"
// #import

// #import "user32.dll"
//    long WindowFromPoint(int x, int y);
//    long GetForegroundWindow();
// #import

//Make sure this is in sync with the C# enum UIMessageIDs
enum UIMessageIDs
{
   BarData = 1,
   BarData2 = 2,
   SetS1Days = 3,
   Config = 4,
   ChartNavigation = 5,
   CountdownUpdate = 6,
   BuySell = 7,
   TradeExecuted = 8,
   AccountBalance = 9,
   FormClosed = 9999
};

//--- Input parameters
input int PanelWidth = 450;  // Width of the control panel
input int PanelHeight = 200; // Height of the control panel
int DaysToShow = 7;          // Number of days to show lines for
input int LowPDR = 4000;
input bool TrackMouse = true; // Track mouse movements on chart

//--- Input separator
input string Separator1 = "=================="; // --- Drawing Settings ---

input color LineColor = clrBlue;               // Color of the horizontal lines
input int LineWidth = 1;                       // Width of the lines
input ENUM_LINE_STYLE LineStyle = STYLE_SOLID; // Style of the lines
input bool EnableDebugLogs = false;            // Enable detailed debug logging
input bool EnableTrading = false;              // Enable automatic trading
input double LotSize = 0.1;                    // Trade lot size
input int StopLoss = 50;                       // Stop loss in points
input int TakeProfit = 100;                    // Take profit in points
input bool ClearAllObjectsOnStart = false;     // Clear all chart objects when EA starts
int DailyStartHour = -1;                       // -1 means not yet detected
bool bSendNotifications = true;                // Enable push notifications for trades
datetime _currentDate;

// Add this global variable at the top with your other globals
bool shouldRemoveEA = false;

//--- Global variables
#include <Trade/Trade.mqh>           // Include trading library
#include "../../Include/MyPanel.mqh" // Path relative to MQL5\Include
#include <Arrays\ArrayLong.mqh>

string line_prefix = "LA_HighLowClose_"; // Prefix for line object names
CArrayLong notified_deals;               // Array to track notified deals
CTrade trade;                            // Trade object
CMyPanel MyUI;

// Global variable to track last position ID (add this at the top of your script if not already there)
ulong lastPositionID = 0;
ulong lastOpenPositionID = 0; // Track last opened position to avoid duplicate notifications

//+------------------------------------------------------------------+
//| Debug print function                                            |
//+------------------------------------------------------------------+
void DebugPrint(string message)
{
   if (EnableDebugLogs)
      Print("[DEBUG] ", message);
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // if (!MyUI.Create(0, "LA Backtest", 0, 350, 20, PanelWidth, PanelHeight))
   //    return INIT_FAILED;

   // MyUI.txtS1Days.Text(IntegerToString(DaysToShow));

   // MyUI.Run();
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);

   // Draw_S1_Lines(D'2025.12.29', 10); // Example date and previous days
   // datetime setDate = StringToTime(MyUI.txtDate.Text());
   // RemoveAllLines();
   // DaysToShow = (int)StringToInteger(MyUI.txtS1Days.Text());
   // Draw_S1_Lines(setDate, DaysToShow);

   // Create timer to update every 1 second
   EventSetMillisecondTimer(100);

   // Get the chart window handle
   long chartHandle = ChartGetInteger(0, CHART_WINDOW_HANDLE);
   Print("Chart Window Handle: ", chartHandle);
   MQLBridge::MQLBridge::StartUI(chartHandle);

   // MQLBridge::MQLBridge::GetLastMessage(1); // Dummy call to ensure DLL is loaded
   // string msg = FetchStringFromDLL();
   // Print("DLL Message: ", msg);
   SetChartShift(20);

   Print("-OnInit()");
   return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Clean up - remove all our lines when EA is removed
   RemoveAllLines();
   EventKillTimer();
   ObjectDelete(0, "UI_Countdown_Label");
   Print("Daily High Close Lines EA deinitialized");
   // MyUI.Destroy(reason);
   // ExpertRemove(); // Ensure the EA is removed from the chart
   Print("-OnDeinit() with reason: ", reason);
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   // Pass all chart events to the UI class
   if (id == CHARTEVENT_OBJECT_CLICK)
   {
      if (sparam == "btnPrev")
      {
         datetime currentDate = StringToTime(MyUI.txtDate.Text());
         datetime previousDate = GetPreviousTradingDay(currentDate);
         MyUI.txtDate.Text(TimeToString(previousDate, TIME_DATE));
         RemoveAllLines();
         Draw_S1_Lines(previousDate, DaysToShow);
      }
      else if (sparam == "btnNext")
      {
         datetime currentDate = StringToTime(MyUI.txtDate.Text());
         datetime nextDate = GetNextTradingDay(currentDate);
         MyUI.txtDate.Text(TimeToString(nextDate, TIME_DATE));
         RemoveAllLines();
         Draw_S1_Lines(nextDate, DaysToShow);
      }
      else if (sparam == "btnSetDate")
      {
         datetime setDate = StringToTime(MyUI.txtDate.Text());
         RemoveAllLines();
         DaysToShow = (int)StringToInteger(MyUI.txtS1Days.Text());
         Draw_S1_Lines(setDate, DaysToShow);
      }
      else if (sparam == "btnCurrentDate")
      {
         datetime now = TimeCurrent();
         MyUI.txtDate.Text(TimeToString(now, TIME_DATE));
         RemoveAllLines();
         DaysToShow = (int)StringToInteger(MyUI.txtS1Days.Text());
         Draw_S1_Lines(now, DaysToShow);
      }
      // Print("Chart event: CLICK at X=" + IntegerToString(lparam) + ", Y=" + IntegerToString((long)dparam) + ", Object: " + sparam );
   }
   else if (id == CHARTEVENT_OBJECT_CHANGE)
   {
      Print("Chart event: OBJECT CHANGE - Object: " + sparam);
   }
   else if (id == CHARTEVENT_MOUSE_MOVE)
   {
      // 1. Static variable to store the 'state' of the last bar we processed
      static datetime last_processed_bar_time = 0;

      int x = (int)lparam;
      int y = (int)dparam;
      datetime current_mouse_time;
      double price;
      int sub_window;

      // 2. Convert pixels to Time/Price
      if (ChartXYToTimePrice(0, x, y, sub_window, current_mouse_time, price))
      {
         // 3. Find the start time of the bar under the mouse
         int bar_index = iBarShift(_Symbol, _Period, current_mouse_time, false);
         datetime bar_start_time = iTime(_Symbol, _Period, bar_index);

         // --- THE THROTTLER ---
         // If we are still over the same bar, exit immediately
         if (bar_start_time == last_processed_bar_time)
         {
            // MyUI.ChartEvent(id, lparam, dparam, sparam);
            return;
         }

         // Update the state for the next move
         last_processed_bar_time = bar_start_time;
         // ---------------------

         // 4. Heavy logic only runs when the mouse moves to a NEW bar
         MqlRates bar;
         if (GetBarUnderMouse(x, y, bar))
         {
            int bo_percent = BreakoutTest(bar_start_time, bar);
            // Print("bo_percent: ", bo_percent);
            string bar_info = "";
            if (bo_percent > 0)
            {
               if (bo_percent > 100)
                  bo_percent = 100; // Cap at 100%
               bar_info = StringFormat("[%s] Body: %d BO %d%%",
                                       FormatTime(bar.time), BarBodySize(bar),
                                       bo_percent);
            }
            else
            {
               bar_info = StringFormat("[%s] Body: %d",
                                       FormatTime(bar.time), BarBodySize(bar));
            }
            // MyUI.lblBarInfo.Text(bar_info);
            SendStringToDLL(bar_info, (int)BarData);

            // bar info 2
            int pips_oc = (int)MathAbs((bar.close - bar.open) / _Point);
            int pips_oh = (int)(MathAbs((bar.close < bar.open ? bar.open - bar.low : bar.high - bar.open)) / _Point);

            string bar_info2 = "";
            if (bar.close > bar.open)
            {
               int pips_r = (int)((bar.open - bar.low) / _Point);
               bar_info2 = StringFormat("↑: %d pips | ↑↑: %d pips | ↓R: %d pips",
                                        pips_oc, pips_oh, pips_r);
               // Print(bar.open, " ", bar.close, " ", bar.high, " ", bar.low , " ", (int)((bar.open - bar.low) * 100));
            }
            else
            {
               int pips_r = (int)((bar.high - bar.open) / _Point);
               bar_info2 = StringFormat("↓: %d pips | ↓↓: %d pips | ↑R: %d pips",
                                        pips_oc, pips_oh, pips_r);
            }

            // MyUI.lblBarInfo2.Text(bar_info2);
            SendStringToDLL(bar_info2, (int)BarData2);

            // Get bar details
            // double o = iOpen(_Symbol, _Period, bar_index);
            // double c = iClose(_Symbol, _Period, bar_index);
            double h = bar.high;
            double l = bar.low;
            // datetime t = iTime(_Symbol, _Period, bar_index);
            // MQLBridge::MQLBridge::UpdateBarDetails(bar_index,o,c,h,l,(long)t);

            // ChartRedraw(0);

            // Get the High/Low of this bar to position the marker
            // double h = iHigh(_Symbol, _Period, bar_index);
            // double l = iLow(_Symbol, _Period, bar_index);

            // UpdateHoverDetails(bar_index,o,c,h,l,(long)t);

            if (TrackMouse)
            {
               DrawMouseMarker(bar_start_time, h, l);
            }
            else
            {
               RemoveMouseMarker();
               ChartRedraw(0);
            }
         }
      }
   }
   else
   {
      // Print("Chart event: ID=",id, " lparam=", lparam, ", dparam=",dparam, ", sparam=",sparam);
   }

   // MyUI.ChartEvent(id, lparam, dparam, sparam);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Check if we should remove the EA
   if (shouldRemoveEA)
   {
      Print("Removing EA on next tick...");
      ExpertRemove();
      return;
   }

   UpdateCountdown();
   //---
}
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
{
   // Select trade history for the current moment
   HistorySelect(TimeCurrent() - 60, TimeCurrent()); // Last 60 seconds to ensure we get the latest deal

   // Get the total number of deals
   int total_deals = HistoryDealsTotal();
   if (total_deals == 0)
      return; // No deals found

   // Get the most recent deal (last in the list)
   ulong deal_ticket = HistoryDealGetTicket(total_deals - 1);
   if (deal_ticket == 0)
      return; // Invalid deal

   // Get deal properties
   long deal_entry = HistoryDealGetInteger(deal_ticket, DEAL_ENTRY);
   long deal_position_id = HistoryDealGetInteger(deal_ticket, DEAL_POSITION_ID);
   string symbol = HistoryDealGetString(deal_ticket, DEAL_SYMBOL);
   long deal_type = HistoryDealGetInteger(deal_ticket, DEAL_TYPE);
   string deal_type_str = (deal_type == DEAL_TYPE_BUY ? "Buy" : "Sell");

   // Handle position opening (DEAL_ENTRY_IN)
   if (deal_entry == DEAL_ENTRY_IN)
   {
      if (lastOpenPositionID == deal_position_id)
      {
         // Skip to avoid duplicate notification for same position opening
         return;
      }
      lastOpenPositionID = deal_position_id;

      double volume = HistoryDealGetDouble(deal_ticket, DEAL_VOLUME);
      double price = HistoryDealGetDouble(deal_ticket, DEAL_PRICE);

      // Get the position to retrieve TP and SL
      if (PositionSelectByTicket(deal_position_id))
      {
         double tp = PositionGetDouble(POSITION_TP);
         double sl = PositionGetDouble(POSITION_SL);
      }
      // Format the notification message for opening
      string message = StringFormat("Position #%lld opened on %s,\r\nType: %s,\r\nVolume: %.2f,\r\nPrice: %.2f",
                                    deal_position_id, symbol, deal_type_str, volume, price);

      // Send push notification
      if (bSendNotifications)
      {
         if (!SendNotification(message))
         {
            Print("Failed to send open notification: ", GetLastError());
         }
         else
         {
            Print("Open notification sent: ", message);
         }
      }
   }

   // Handle position closing (DEAL_ENTRY_OUT)
   else if (deal_entry == DEAL_ENTRY_OUT)
   {
      if (lastPositionID == deal_position_id)
      {
         // Skip to avoid duplicate notification for same position closure
         return;
      }
      lastPositionID = deal_position_id;

      double profit = HistoryDealGetDouble(deal_ticket, DEAL_PROFIT);
      double volume = HistoryDealGetDouble(deal_ticket, DEAL_VOLUME);
      double price = HistoryDealGetDouble(deal_ticket, DEAL_PRICE);

      // 1. Get the Entry Price by selecting the position history
      double entry_price = 0;
      if (HistorySelectByPosition(deal_position_id))
      {
         int total_deals = HistoryDealsTotal();
         for (int i = 0; i < total_deals; i++)
         {
            ulong t = HistoryDealGetTicket(i);
            // Look for the "In" deal for this position
            if (HistoryDealGetInteger(t, DEAL_ENTRY) == DEAL_ENTRY_IN)
            {
               entry_price = HistoryDealGetDouble(t, DEAL_PRICE);
               break;
            }
         }
      }

      // Format the notification message for closing
      string message = "";
      if (entry_price != 0)
      {
         int profit_pips = (int)(MathAbs(entry_price - price)) * 100;

         message = StringFormat("Position closed\r\nType: %s\r\nVolume: %.2f\r\nPrice: %.2f\r\nProfit: %.2f\r\nProfit Pips: %d",
                                deal_type_str, volume, price, profit, profit_pips);
      }
      else
      {
         message = StringFormat("Position closed\r\nType: %s\r\nVolume: %.2f\r\nPrice: %.2f\r\nProfit: %.2f",
                                deal_type_str, volume, price, profit);
      }

      // Send push notification
      if (bSendNotifications)
      {
         if (!SendNotification(message))
         {
            Print("Failed to send close notification: ", GetLastError());
         }
         else
         {
            Print("Close notification sent: ", message);
         }
      }
   }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Function to remove all lines created by this EA                 |
//+------------------------------------------------------------------+
void RemoveAllLines()
{
   DebugPrint(">> RemoveAllLines: Starting cleanup...");

   // Get total number of objects on the chart
   int total_objects = ObjectsTotal(0);
   int removed_count = 0;

   DebugPrint("Total objects on chart: " + IntegerToString(total_objects));

   // Loop through all objects and remove those with our prefix
   for (int i = total_objects - 1; i >= 0; i--)
   {
      string obj_name = ObjectName(0, i);

      // Check if object name starts with our prefix
      if (StringFind(obj_name, line_prefix) == 0)
      {
         DebugPrint("Removing object: " + obj_name);
         if (ObjectDelete(0, obj_name))
         {
            removed_count++;
            DebugPrint("Successfully removed: " + obj_name);
         }
         else
         {
            DebugPrint("Failed to remove: " + obj_name);
         }
      }
   }

   DebugPrint("Cleanup complete. Removed " + IntegerToString(removed_count) + " objects");
}

//+------------------------------------------------------------------+
//| Get all bars for a specific calendar date                        |
//+------------------------------------------------------------------+
int GetBarsByDate(const string symbol,
                  const ENUM_TIMEFRAMES timeframe,
                  const datetime date,
                  MqlRates &rates[])
{
   // Print("+GetBarsByDate(): Date = ", TimeToString(date, TIME_DATE));

   // 1. Normalize to 00:00:00 of the given date
   MqlDateTime dt_struct;
   TimeToStruct(date, dt_struct);
   dt_struct.hour = 0;
   dt_struct.min = 0;
   dt_struct.sec = 0;

   datetime start_of_day = StructToTime(dt_struct);
   datetime end_of_day = start_of_day + 86399; // 23:59:59

   // 2. Prepare the array
   ArrayFree(rates);
   ArraySetAsSeries(rates, false); // Index 0 = First bar of that day

   // 3. Request data for the specific range
   ResetLastError();
   int copied = CopyRates(symbol, timeframe, start_of_day, end_of_day, rates);

   if (copied <= 0)
   {
      PrintFormat("No bars found for %s on %s. Error: %d",
                  symbol, TimeToString(start_of_day, TIME_DATE), GetLastError());
      return 0;
   }

   // --- MODIFICATION START ---
   // Check if start_of_day is the same as the current server date
   datetime current_server_time = TimeCurrent();
   MqlDateTime dt_today;
   TimeToStruct(current_server_time, dt_today);
   dt_today.hour = 0;
   dt_today.min = 0;
   dt_today.sec = 0;
   datetime today_normalized = StructToTime(dt_today);

   // Only look for the "next day bar" if the target date is in the past
   if (start_of_day < today_normalized)
   {
      // include bar for next day 00:00 if exists
      MqlRates next_day_bar[];
      datetime next_day = AddOneDay(start_of_day);
      int tries = 0, next_copied = 0;

      while (tries < 5 && next_copied == 0)
      {
         // Print("Checking for next day bar on date: ", TimeToString(next_day, TIME_DATE));
         next_copied = CopyRates(symbol, timeframe, next_day, next_day + 3601, next_day_bar);

         if (next_copied > 0)
         {
            // Print("Found next day bar for date: ", TimeToString(next_day, TIME_DATE));

            // Append next day bar to rates array
            int original_size = ArraySize(rates);
            ArrayResize(rates, original_size + 1);
            rates[original_size] = next_day_bar[0];
            copied += 1;
            break;
         }

         next_day = AddOneDay(next_day);
         tries++;
      }
   }
   else
   {
      // Print("Target date is today. Skipping next-day bar check.");
   }
   // --- MODIFICATION END ---

   return copied;
}

//+------------------------------------------------------------------+
//| Print MqlRates array to the terminal log                         |
//+------------------------------------------------------------------+
void PrintBars(const MqlRates &rates[])
{
   int size = ArraySize(rates);
   if (size == 0)
   {
      Print("PrintBars: Array is empty.");
      return;
   }

   Print("--- Debug Print: Bars Found ---");
   PrintFormat("%-5s | %-20s | %-8s | %-8s | %-8s | %-8s",
               "Index", "Time", "Open", "High", "Low", "Close");
   Print("------------------------------------------------------------------");

   for (int i = 0; i < size; i++)
   {
      string timeStr = TimeToString(rates[i].time, TIME_DATE | TIME_MINUTES | TIME_SECONDS);

      PrintFormat("[%3d] | %-20s | %-8.2f | %-8.2f | %-8.2f | %-8.2f",
                  i,
                  timeStr,
                  rates[i].open,
                  rates[i].high,
                  rates[i].low,
                  rates[i].close);
   }
   Print("--- End of Debug Print ---");
}

//+------------------------------------------------------------------+
//| Get the highest body top (Close if Bullish, Open if Bearish)     |
//+------------------------------------------------------------------+
double GetHighestBodyPrice(const MqlRates &rates[], int &out_index)
{
   // Print("+GetHighestBodyPrice()");
   int size = ArraySize(rates);
   if (size <= 0)
      return 0.0;

   out_index = 0;
   // Initial comparison value for the first bar
   double highest = (rates[0].close >= rates[0].open) ? rates[0].close : rates[0].open;

   for (int i = 1; i < size; i++)
   {
      // If bullish (or doji), use Close. If bearish, use Open.
      double currentBodyTop = (rates[i].close >= rates[i].open) ? rates[i].close : rates[i].open;

      if (currentBodyTop > highest)
      {
         highest = currentBodyTop;
         out_index = i;
      }
   }

   return highest;
}

//+------------------------------------------------------------------+
//| Get the highest body top (Close if Bullish, Open if Bearish)     |
//+------------------------------------------------------------------+
double GetLowestBodyPrice(const MqlRates &rates[], int &out_index)
{
   int size = ArraySize(rates);
   if (size <= 0)
      return 0.0;

   out_index = 0;
   // Initial comparison value for the first bar
   double lowest = (rates[0].close <= rates[0].open) ? rates[0].close : rates[0].open;

   for (int i = 1; i < size; i++)
   {
      // If bullish (or doji), use Close. If bearish, use Open.
      double currentBodyLow = (rates[i].close <= rates[i].open) ? rates[i].close : rates[i].open;

      if (currentBodyLow < lowest)
      {
         lowest = currentBodyLow;
         out_index = i;
      }
   }

   return lowest;
}

double GetLowestBodyPriceByDate(datetime targetdate)
{
   MqlRates rates[];
   int size = GetBarsByDate(_Symbol, PERIOD_H1, targetdate, rates);
   if (size <= 0)
      return 0.0;

   int out_index = 0;
   // Initial comparison value for the first bar
   double lowest = (rates[0].close <= rates[0].open) ? rates[0].close : rates[0].open;

   for (int i = 1; i < size; i++)
   {
      // If bullish (or doji), use Close. If bearish, use Open.
      double currentBodyLow = (rates[i].close <= rates[i].open) ? rates[i].close : rates[i].open;

      if (currentBodyLow < lowest)
      {
         lowest = currentBodyLow;
         out_index = i;
      }
   }

   return lowest;
}

double GetHighestBodyPriceByDate(datetime targetdate)
{
   MqlRates rates[];
   // Print("+GetHighestBodyPrice()");
   int size = GetBarsByDate(_Symbol, PERIOD_H1, targetdate, rates);
   if (size <= 0)
      return 0.0;

   // Initial comparison value for the first bar
   double highest = (rates[0].close >= rates[0].open) ? rates[0].close : rates[0].open;

   for (int i = 1; i < size; i++)
   {
      // If bullish (or doji), use Close. If bearish, use Open.
      double currentBodyTop = (rates[i].close >= rates[i].open) ? rates[i].close : rates[i].open;

      if (currentBodyTop > highest)
      {
         highest = currentBodyTop;
      }
   }
   return highest;
}

void Draw_S1_Lines(datetime targetDate, int prevDays)
{
   MqlRates dayBars[];

   // Draw vertical line at start of the target date
   DrawVerticalLine(targetDate);

   // S1 lines for target date will start from previous day
   datetime prevday = SubtractOneDay(targetDate);
   int total = GetBarsByDate(_Symbol, PERIOD_H1, prevday, dayBars);

   while (total == 0)
   {
      // no bars found, go back one more day
      prevday = SubtractOneDay(prevday);
      total = GetBarsByDate(_Symbol, PERIOD_H1, prevday, dayBars);
   }

   int index = 0;
   double high_price, low_price = 0.0;
   string desc = "";

   if (total > 0)
   {
      // Print("Found ", total, " bars.");
      // dayBars[0] will be the 23:45 bar (if using ArraySetAsSeries)
      // dayBars[total-1] will be the 00:00 bar
      // PrintBars(dayBars);

      high_price = GetHighestBodyPrice(dayBars, index);
      desc = "High_" + TimeToString(prevday, TIME_DATE);
      Draw_Line(high_price, desc, 0);

      low_price = GetLowestBodyPrice(dayBars, index);
      desc = "Low_" + TimeToString(prevday, TIME_DATE);
      Draw_Line(low_price, desc, 0);

      // DrawPeriodDetails(prevday); // Place label slightly above the low line
      DrawPDRLabel(prevday, high_price, low_price);
      DrawBoxDaily(prevday, high_price, low_price);
   }

   if (prevDays > 0)
   {
      // Draw S1 lines from n previous days
      int count = prevDays;

      datetime currentDay = prevday;
      while (count > 0)
      {
         // get prvious day date
         datetime prevDay = SubtractOneDay(currentDay);
         total = GetBarsByDate(_Symbol, PERIOD_H1, prevDay, dayBars);
         if (total > 0)
         {
            // we have bars, draw S1 lines
            high_price = GetHighestBodyPrice(dayBars, index);
            desc = "High_" + TimeToString(prevDay, TIME_DATE);
            Draw_Line(high_price, desc, 1);

            low_price = GetLowestBodyPrice(dayBars, index);
            desc = "Low_" + TimeToString(prevDay, TIME_DATE);
            Draw_Line(low_price, desc, 1);
            // DrawPeriodDetails(prevDay);
            DrawPDRLabel(prevDay, high_price, low_price);
            DrawBoxDaily(prevDay, high_price, low_price);
            count = count - 1;
         }

         currentDay = prevDay;
      }
   }
}

void Draw_Line(double price, string desc, int style)
{
   // Create unique name for this line
   string line_name = line_prefix + "_" + desc;
   DebugPrint("Creating line with name: " + line_name);
   DebugPrint("Line price: " + DoubleToString(price, _Digits));

   // Create horizontal line
   if (ObjectCreate(0, line_name, OBJ_HLINE, 0, 0, price))
   {
      // Set line properties
      if (style == 0)
      {
         ObjectSetInteger(0, line_name, OBJPROP_COLOR, clrRed);
         ObjectSetInteger(0, line_name, OBJPROP_WIDTH, 2);
         ObjectSetInteger(0, line_name, OBJPROP_STYLE, LineStyle);
      }
      else
      {
         ObjectSetInteger(0, line_name, OBJPROP_COLOR, LineColor);
         ObjectSetInteger(0, line_name, OBJPROP_WIDTH, LineWidth);
         ObjectSetInteger(0, line_name, OBJPROP_STYLE, STYLE_DOT);
      }

      ObjectSetInteger(0, line_name, OBJPROP_BACK, true); // Draw line in background
      ObjectSetString(0, line_name, OBJPROP_TEXT, line_name);

      // Ensure it doesn't get in the way of clicking bars
      ObjectSetInteger(0, line_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, line_name, OBJPROP_SELECTED, false);

      // Print("✓ Created line.");
   }
   else
   {
      Print("✗ Failed to create line for price ", price);
   }
}

//+------------------------------------------------------------------+
//| Draw or move a vertical line on the chart                        |
//+------------------------------------------------------------------+
void DrawVerticalLine(const datetime time)
{
   // Get the start hour for this specific date
   int startHour = GetCachedDayStartHour(time);

   if (startHour == -1)
   {
      Print("Cannot draw vertical line - no trading session found for ", TimeToString(time, TIME_DATE));
      return;
   }

   // Normalize to start of day (00:00)
   MqlDateTime dt;
   TimeToStruct(time, dt);
   dt.hour = startHour;
   dt.min = 0;
   dt.sec = 0;
   datetime startOfDay = StructToTime(dt);

   string name = line_prefix + "_DayStart_" + TimeToString(startOfDay, TIME_DATE);

   // 1. Try to create the object (Chart ID 0 is the current chart)
   // OBJ_VLINE only requires 'time' (price is ignored)
   if (!ObjectCreate(0, name, OBJ_VLINE, 0, startOfDay, 0))
   {
      // If creation fails because it exists, just move the existing one
      ObjectMove(0, name, 0, startOfDay, 0);
   }

   // 2. Set visual properties
   ObjectSetInteger(0, name, OBJPROP_COLOR, LineColor);
   ObjectSetInteger(0, name, OBJPROP_STYLE, LineStyle);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);

   // 3. Hide name in the background (optional)
   ObjectSetInteger(0, name, OBJPROP_BACK, true);

   // Ensure it doesn't get in the way of clicking bars
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);

   // 3. Find the bar index for this time
   // exact = false allows it to find the nearest bar if 01:00 doesn't have a bar
   int barIndex = iBarShift(_Symbol, _Period, startOfDay, false);

   if (barIndex != -1)
   {
      // --- NEW: VISIBILITY CHECK ---

      // Get the index of the leftmost bar currently visible
      long firstVisibleBar = ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
      // Get how many bars are currently shown on the screen
      long visibleBarsCount = ChartGetInteger(0, CHART_VISIBLE_BARS);

      // Calculate the rightmost visible bar index
      long lastVisibleBar = firstVisibleBar - visibleBarsCount;

      // Check if our target barIndex is outside the current view
      // If barIndex > firstVisibleBar, it's off-screen to the left (history)
      // If barIndex < lastVisibleBar, it's off-screen to the right (future)
      if (barIndex > firstVisibleBar || barIndex < lastVisibleBar)
      {
         // 4. Disable Auto-scroll to prevent snapping back to the current tick
         ChartSetInteger(0, CHART_AUTOSCROLL, false);

         // 5. Navigate: Position the bar roughly in the middle-left (offset by 10)
         ChartNavigate(0, CHART_END, -(barIndex + 10));

         Print("Line was off-screen. Navigating to bar: ", barIndex);
      }
      else
      {
         Print("Line is already visible. Skipping navigation.");
      }
   }

   // 4. Force a chart refresh to show the change immediately
   ChartRedraw(0);
}

void DrawPDRLabel(const datetime targetdate, double price_high, double price_low)
{
   // 1. Normalize to the start of the given day
   MqlDateTime dt;
   TimeToStruct(targetdate, dt);
   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;

   // 2. Calculate the middle of the day (12:00:00)
   datetime middleTime = StructToTime(dt) + 43200;
   string name = line_prefix + "_PDR_" + TimeToString(targetdate, TIME_DATE);

   double pdr = (price_high - price_low) * 100;
   string text = StringFormat("[%s] %d pips", GetDayName(targetdate), (int)pdr);
   DrawPeriodLabel(targetdate, text, price_low - 300 * _Point);
}

//+------------------------------------------------------------------+
//| Place a text label in the middle (12:00) of a specific day       |
//+------------------------------------------------------------------+
void DrawPeriodDetails(const datetime targetdate)
{
   // 1. Normalize to the start of the given day
   MqlDateTime dt;
   TimeToStruct(targetdate, dt);
   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;

   // 2. Calculate the middle of the day (12:00:00)
   datetime middleTime = StructToTime(dt) + 43200;
   string name = line_prefix + "_PDR_" + TimeToString(targetdate, TIME_DATE);

   // GET PDR of targetdate
   MqlRates rates[];
   int bars = GetBarsByDate(_Symbol, PERIOD_H1, targetdate, rates);

   if (bars == 0)
   {
      // Print("+DrawPeriodDetails() No bars found for PDR calculation on date: " + TimeToString(targetdate, TIME_DATE));
      return;
   }
   // Print("+DrawPeriodDetails() Calculating PDR for date: " + TimeToString(targetdate, TIME_DATE));

   int pdr_rate = (int)(GetHighestBodyPrice(rates, bars) - GetLowestBodyPrice(rates, bars)) * 100;

   // Draw PDR below lowest price
   //  double lowprice = GetLowestBodyPrice(rates, bars);
   double lowprice = GetLowestBodyPriceByDate(targetdate);

   // Write PDR label
   DrawPeriodLabel(targetdate, "PDR: " + IntegerToString(pdr_rate), lowprice - 300 * _Point);

   ChartRedraw(0);
}

void DrawPeriodLabel(const datetime targetdate, const string text, double price)
{
   // 1. Normalize to the start of the given day
   MqlDateTime dt;
   TimeToStruct(targetdate, dt);
   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;

   // 2. Calculate the middle of the day (12:00:00)
   datetime middleTime = StructToTime(dt) + 43200;

   string name = line_prefix + "_Label_" + TimeToString(targetdate, TIME_DATE);
   // Print("+DrawPeriodLabel(): Drawing label '" + text + "' at " + TimeToString(middleTime) + " Price: " + DoubleToString(price, _Digits));
   // 3. Create or Move the Text Object
   if (!ObjectCreate(0, name, OBJ_TEXT, 0, middleTime, price))
   {
      ObjectMove(0, name, 0, middleTime, price);
   }

   // 4. Set Properties
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, name, OBJPROP_FONT, "Trebuchet MS");

   // ANCHOR_CENTER ensures the text is balanced 50/50 over the 12:00 mark
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, name, OBJPROP_BACK, true); // Draw line in background
   // Ensure it doesn't get in the way of clicking bars
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);

   // ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Subtract exactly 24 hours from a datetime                        |
//+------------------------------------------------------------------+
datetime SubtractOneDay(const datetime source_time)
{
   return (source_time - 86400);
}

//+------------------------------------------------------------------+
//| Add exactly 24 hours from a datetime                        |
//+------------------------------------------------------------------+
datetime AddOneDay(const datetime source_time)
{
   return (source_time + 86400);
}

datetime GetPreviousTradingDay(datetime source_time)
{
   datetime prev_day = SubtractOneDay(source_time);
   MqlRates rates[];
   int total = GetBarsByDate(_Symbol, PERIOD_D1, prev_day, rates);

   while (total == 0)
   {
      // no bars found, go back one more day
      prev_day = SubtractOneDay(prev_day);
      total = GetBarsByDate(_Symbol, PERIOD_D1, prev_day, rates);
   }

   return prev_day;
}

datetime GetNextTradingDay(datetime source_time)
{
   datetime next_day = AddOneDay(source_time);
   datetime current_server_time = TimeCurrent();

   if (next_day > current_server_time)
   {
      return source_time;
   }

   MqlRates rates[];
   int total = GetBarsByDate(_Symbol, PERIOD_D1, next_day, rates);

   while (total == 0)
   {
      // no bars found, go forward one more day
      next_day = AddOneDay(next_day);

      if (next_day > current_server_time)
      {
         return source_time;
      }

      total = GetBarsByDate(_Symbol, PERIOD_D1, next_day, rates);
   }

   return next_day;
}

//+------------------------------------------------------------------+
//| Get bar details under specific pixel coordinates                 |
//+------------------------------------------------------------------+
bool GetBarUnderMouse(int x, int y, MqlRates &bar_details)
{
   datetime time;
   double price;
   int sub_window;

   // 1. Convert pixels to Time and Price
   if (!ChartXYToTimePrice(0, x, y, sub_window, time, price))
      return false;

   // 2. Find the index of the bar at that time
   // exact = false finds the bar the mouse is "over" even if not pixel-perfect
   int bar_index = iBarShift(_Symbol, _Period, time, false);

   if (bar_index == -1)
      return false;

   // 3. Copy the bar data into the struct
   MqlRates rates[];
   if (CopyRates(_Symbol, _Period, bar_index, 1, rates) > 0)
   {
      bar_details = rates[0];
      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| Format datetime to YY.MM.DD HH                                   |
//+------------------------------------------------------------------+
string FormatTime(datetime time)
{
   MqlDateTime dt;
   TimeToStruct(time, dt);

   // dt.year % 100 gives us the last two digits (e.g., 2025 -> 25)
   // %02d ensures leading zeros (e.g., 5 -> 05)
   return StringFormat("%d.%02d.%02d %02d:%02d",
                       dt.year,
                       dt.mon,
                       dt.day,
                       dt.hour,
                       dt.min);
}

int BarBodySize(const MqlRates &bar)
{
   return (int)MathAbs((bar.close - bar.open) * 100);
}

//+------------------------------------------------------------------+
//| Draw a rectangle spanning a specific day using provided prices   |
//+------------------------------------------------------------------+
void DrawBoxDaily(datetime date, double y_high, double y_low)
{
   // Get the start hour for this specific date
   int startHour = GetCachedDayStartHour(date);

   if (startHour == -1)
   {
      Print("Cannot draw vertical line - no trading session found for ", TimeToString(date, TIME_DATE));
      return;
   }

   // 1. Normalize to get the X-axis boundaries (Start and End of day)
   MqlDateTime dt_struct;
   TimeToStruct(date, dt_struct);
   dt_struct.hour = startHour;
   dt_struct.min = 0;
   dt_struct.sec = 0;

   datetime x1 = StructToTime(dt_struct);
   // datetime x2 = x1 + 86399 + 3600; // 23:59:59 (Period Separator)
   datetime x2 = GetNextTradingDay(x1); // 23:59:59 (Period Separator)

   // 2. Define a unique object name based on the date
   string name = line_prefix + "_PriceBox_" + TimeToString(x1, TIME_DATE);

   ResetLastError();

   // 3. Create or Move the Rectangle
   // Anchor 1: (x1, y_high) | Anchor 2: (x2, y_low)
   if (!ObjectCreate(0, name, OBJ_RECTANGLE, 0, x1, y_high, x2, y_low))
   {
      // If it already exists, update all 4 coordinates
      ObjectMove(0, name, 0, x1, y_high);
      ObjectMove(0, name, 1, x2, y_low);
   }

   // 4. Set Visual Properties
   double pdr = (y_high - y_low) * 100;
   if (pdr < LowPDR)
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrGold);
   else
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrMistyRose);

   ObjectSetInteger(0, name, OBJPROP_FILL, true); // Fill the box
   ObjectSetInteger(0, name, OBJPROP_BACK, true); // Ensure candles are in front
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);

   // Optional: Set transparency if your broker/terminal supports it via color
   // Note: MT5 fill uses the same color as the border

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Get the full name of the day from a datetime value               |
//+------------------------------------------------------------------+
string GetDayName(datetime time)
{
   // 1. Convert datetime to the MqlDateTime structure
   MqlDateTime dt;
   TimeToStruct(time, dt);

   // 2. Define a static array for mapping (0=Sunday ... 6=Saturday)
   static const string dayNames[] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};

   // 3. Return the name based on the index
   // Bounds check is a good practice for defensive programming
   if (dt.day_of_week < 0 || dt.day_of_week > 6)
      return "Unknown";

   return dayNames[dt.day_of_week];
}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
   // 1. We look for 'TRADE_TRANSACTION_HISTORY_ADD'
   // This indicates a deal has been moved to history (a fill or a close)
   // if (trans.type == TRADE_TRANSACTION_HISTORY_ADD)
   // {
   //    ProcessClosedNotification(trans.deal);
   // }
}

//+------------------------------------------------------------------+
//| Helper to filter and send notification                           |
//+------------------------------------------------------------------+
void ProcessClosedNotification(ulong deal_id)
{
   // 2. Check if we already notified this specific Deal ID
   if (notified_deals.SearchLinear(deal_id) != -1)
      return; // Already sent, exit.

   // 3. Select the deal from history to verify it's a "Close"
   if (HistoryDealSelect(deal_id))
   {
      long entry = HistoryDealGetInteger(deal_id, DEAL_ENTRY);

      // We only care about DEAL_ENTRY_OUT (Close) or DEAL_ENTRY_INOUT (Reverse)
      if (entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_INOUT)
      {
         string symbol = HistoryDealGetString(deal_id, DEAL_SYMBOL);
         double profit = HistoryDealGetDouble(deal_id, DEAL_PROFIT);
         double commission = HistoryDealGetDouble(deal_id, DEAL_COMMISSION);
         double swap = HistoryDealGetDouble(deal_id, DEAL_SWAP);
         double net_profit = profit + commission + swap;

         // 4. Construct the message
         string msg = StringFormat("Order Closed: %s\nID: %I64u\nNet Profit: %.2f",
                                   symbol, deal_id, net_profit);

         // 5. Send Push Notification
         if (SendNotification(msg))
         {
            // 6. Add to list so we don't send it again
            notified_deals.Add(deal_id);
            notified_deals.Sort(); // Keep sorted for faster searching if list grows

            Print("Notification sent for Deal: ", deal_id);
         }
         else
         {
            Print("Failed to send notification. Error: ", GetLastError());
         }
      }
   }
}

int BreakoutTest(datetime targetdate, MqlRates &bar)
{
   // Print("+BreakoutTest(): Date = ", TimeToString(targetdate, TIME_DATE));
   MqlRates dayBars[];
   MqlDateTime dt;
   TimeToStruct(bar.time, dt);
   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;
   datetime bar_start_time = StructToTime(dt);

   // S1 lines for target date will start from previous day
   datetime prevday = SubtractOneDay(bar_start_time);
   int total = GetBarsByDate(_Symbol, PERIOD_H1, prevday, dayBars);

   while (total == 0)
   {
      // no bars found, go back one more day
      prevday = SubtractOneDay(prevday);
      total = GetBarsByDate(_Symbol, PERIOD_H1, prevday, dayBars);
   }

   int high_price = (int)(GetHighestBodyPrice(dayBars, total) * 100);
   int low_price = (int)(GetLowestBodyPrice(dayBars, total) * 100);
   int bar_high_price = (int)(bar.close > bar.open ? bar.close * 100 : bar.open * 100);
   int bar_low_price = (int)(bar.open > bar.close ? bar.close * 100 : bar.open * 100);

   // Print("BreakoutTest - high_price: ", high_price, " low_price: ", low_price);
   // Print("BreakoutTest - bar_high_price: ", bar_high_price, " bar_low_price: ", bar_low_price);
   double bar_body = MathAbs((bar.close - bar.open) * 100);

   if (bar_high_price > high_price)
   {
      double breakout_amount = bar_high_price - high_price;
      int breakout_percent = (int)((breakout_amount / bar_body) * 100);
      // Print("breakout_percent: ", IntegerToString(breakout_percent));
      // Print("Breakout Amount: ", IntegerToString((int)breakout_amount), " Body: ", bar_body);
      return (int)breakout_percent; // Return bullish breakout percentage
   }
   else if (bar_low_price < low_price)
   {
      double breakout_amount = MathAbs(bar_low_price - low_price);
      int breakout_percent = (int)((breakout_amount / bar_body) * 100);
      // Print("Breakout Amount: ", IntegerToString((int)breakout_amount), " Body: ", bar_body);
      return (int)breakout_percent; // Return bearish breakout percentage (negative)
   }
   else
      return 0; // No Breakout
}

void DrawMouseMarker(datetime time, double high, double low)
{
   string line_name = "UI_Mouse_Marker";
   string text_name = "UI_Mouse_Text";
   string rect_name = "UI_Mouse_Box"; // Name for the container

   // 1. Calculate Offsets
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   // Your current logic: 5.0 is a large price jump for FX, but works for Indices/Crypto
   double p_top = high + 5.0;
   double p_bottom = low - 5.0;

   // 2. --- DRAW THE LINE (OBJ_TREND) ---
   if (!ObjectCreate(0, line_name, OBJ_TREND, 0, time, p_top, time, p_bottom))
   {
      ObjectMove(0, line_name, 0, time, p_top);
      ObjectMove(0, line_name, 1, time, p_bottom);
   }
   ObjectSetInteger(0, line_name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, line_name, OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, line_name, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, line_name, OBJPROP_BACK, true);

   // 3. --- PREPARE DATA ---
   MqlDateTime dt;
   TimeToStruct(time, dt);
   string hourText = StringFormat("%02d:%02d", dt.hour, dt.min);

   // We use the text position as our anchor for the box
   datetime x_text = time + 3600;
   double y_text = p_top;

   // 4. --- DRAW THE RECTANGLE (OBJ_RECTANGLE) ---
   // We define the box boundaries relative to the text position
   // Adjust these multipliers as you add more text
   datetime x1 = x_text - 3600;       // Half bar left
   datetime x2 = x_text + (3600 * 7); // Half bar right
   double y1 = y_text + 2.0;          // Slightly above text
   double y2 = y_text - 2.0;          // Slightly below text

   // if(!ObjectCreate(0, rect_name, OBJ_RECTANGLE, 0, x1, y1, x2, y2))
   // {
   //    ObjectMove(0, rect_name, 0, x1, y1);
   //    ObjectMove(0, rect_name, 1, x2, y2);
   // }

   // ObjectSetInteger(0, rect_name, OBJPROP_COLOR, clrLightBlue);      // Border color
   // ObjectSetInteger(0, rect_name, OBJPROP_FILL, true);          // Fill the box
   // ObjectSetInteger(0, rect_name, OBJPROP_BGCOLOR, clrBlack);   // Background color
   // ObjectSetInteger(0, rect_name, OBJPROP_BACK, true);          // Ensure it's behind text
   // ObjectSetInteger(0, rect_name, OBJPROP_SELECTABLE, false);

   // 5. --- DRAW THE TEXT (OBJ_TEXT) ---
   int barOffsetSeconds = PeriodSeconds(_Period) / 2; // Default to half a bar offset
   switch (_Period)
   {
   case PERIOD_M5:
      barOffsetSeconds = 300 / 4; // 5 minutes
      break;
   case PERIOD_M15:
      barOffsetSeconds = 900 / 3; // 15 minutes
      break;
   case PERIOD_M30:
      barOffsetSeconds = 1800 / 2; // 30 minutes
      break;
   case PERIOD_H1:
      barOffsetSeconds = 3600; // 1 hour
      break;
   case PERIOD_H4:
      barOffsetSeconds = 14400; // 4 hours
      break;
   case PERIOD_D1:
      barOffsetSeconds = 86400; // 1 day
      break;
   default:
      break;
   }
   if (!ObjectCreate(0, text_name, OBJ_TEXT, 0, x_text + barOffsetSeconds, y_text))
   {
      ObjectMove(0, text_name, 0, x_text, y_text);
   }

   ObjectSetString(0, text_name, OBJPROP_TEXT, hourText);
   ObjectSetString(0, text_name, OBJPROP_FONT, "Trebuchet MS");
   ObjectSetInteger(0, text_name, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, text_name, OBJPROP_COLOR, clrGreen);
   ObjectSetInteger(0, text_name, OBJPROP_ANCHOR, ANCHOR_CENTER); // Changed to center for the box
   ObjectSetInteger(0, text_name, OBJPROP_SELECTABLE, false);

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Remove the vertical marker and its associated hour text          |
//+------------------------------------------------------------------+
void RemoveMouseMarker()
{
   // 1. Delete both components by their specific names
   // ObjectDelete returns true if successful, but we don't need to check it here
   ObjectDelete(0, "UI_Mouse_Marker");
   ObjectDelete(0, "UI_Mouse_Text");

   // 2. Force a chart refresh to clear the "ghost" images of the deleted objects
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   // If flagged for removal, don't process anything
   if (shouldRemoveEA)
      return;

   CheckUIEvents();

   // Then do other timer tasks
   if (!shouldRemoveEA) // Check again in case event set the flag
      UpdateCountdown();
}

void CheckUIEvents()
{
   // Use a loop to process ALL pending events in the queue
   int maxEvents = 10; // Safety limit to prevent infinite loops
   int processedCount = 0;

   while (processedCount < maxEvents)
   {
      int eventID = MQLBridge::MQLBridge::PeekNextEvent();

      if (eventID == 0)
         break; // No more events in queue

      // Get the actual event data
      ushort buffer[256];
      ArrayInitialize(buffer, 0);
      MQLBridge::MQLBridge::GetNextEvent(buffer, 256);

      string eventMessage = ShortArrayToString(buffer);
      Print("Processing event: ", eventMessage);

      // Process the event
      if (!ProcessUIEvent(eventMessage))
      {
         // If ProcessUIEvent returns false, it means we should stop (form closed)
         break;
      }

      processedCount++;
   }
}

bool ProcessUIEvent(string eventMessage)
{
   // Parse the comma-separated message
   int commaPos = StringFind(eventMessage, ",");
   if (commaPos == -1)
      return true; // Invalid format, continue processing other events

   string eventIDStr = StringSubstr(eventMessage, 0, commaPos);
   string eventData = StringSubstr(eventMessage, commaPos + 1);

   int eventID = (int)StringToInteger(eventIDStr);

   Print("Event ID: ", eventID, " | Data: ", eventData);

   // Process based on event ID
   switch (eventID)
   {
   case BarData:
      Print("Bar Data Event: ", eventData);
      break;

   case SetS1Days:
   {
      datetime _currentDate = StringToTime(eventData);
      datetime nextDate = GetNextTradingDay(_currentDate);
      RemoveAllLines();
      DailyStartHour = -1; // Reset to force re-detection
      Draw_S1_Lines(nextDate, DaysToShow);
      break;
   }
   case Config:
   {
      string parts[];
      StringSplit(eventData, ',', parts);
      // Now 'parts' contains each value as a separate string
      //[S1Days, SendNotification]
      if (parts[0] != "")
      {
         DaysToShow = (int)StringToInteger(parts[0]);
         // Print("Updated DaysToShow: ", DaysToShow);
      }

      if (parts[1] != "")
      {
         bSendNotifications = (bool)StringToInteger(parts[1]);
         // Print("Updated bSendNotifications: ", bSendNotifications);
      }
      // RefreshChart();

      break;
   }
   case ChartNavigation:
   {
      string direction = eventData; // "Left" or "Right"
      StringToLower(direction);
      MoveChartBars(direction, 1);
      break;
   }
   case BuySell:
   {
      // Parse: "BUY|0.1|100|50"
      string parts[];
      StringSplit(eventData, '|', parts);
      
      if (ArraySize(parts) == 4)
      {
         string direction = parts[0];
         double lots = StringToDouble(parts[1]);
         int tp = (int)StringToInteger(parts[2]);
         int sl = (int)StringToInteger(parts[3]);
         
         if (direction == "BUY")
         {
            AutoTrade(TRADE_BUY, lots, tp, sl, "UI Trade");
         }
         else if (direction == "SELL")
         {
            AutoTrade(TRADE_SELL, lots, tp, sl, "UI Trade");
         }

         SendStringToDLL("TradeExecuted", (int)TradeExecuted);
      }
      break;
   }
   case FormClosed:
   {
      Print("===== FORM CLOSED EVENT RECEIVED =====");
      Print("Starting cleanup sequence...");

      // 1. Kill the timer first to stop new events
      EventKillTimer();
      Print("Timer killed");

      // 2. Clean up all objects
      RemoveAllLines();
      Print("Lines removed");

      ObjectDelete(0, "UI_Countdown_Label");
      Print("Countdown label deleted");

      // 3. Force chart redraw
      ChartRedraw(0);
      Print("Chart redrawn");

      // 4. Remove the EA
      // 4. Set flag to remove EA on next tick (NOT here)
      shouldRemoveEA = true;
      Print("EA removal flag set - will remove on next tick");

      // Return false to stop processing more events
      return false;
   }

   default:
      Print("Unknown Event ID: ", eventID);
      break;
   }

   return true; // Continue processing events
}

void RefreshChart()
{
   datetime nextDate = GetNextTradingDay(_currentDate);
   RemoveAllLines();
   DailyStartHour = -1; // Reset to force re-detection
   Draw_S1_Lines(nextDate, DaysToShow);
}

//+------------------------------------------------------------------+
//| Logic to calculate and display time                              |
//+------------------------------------------------------------------+
void UpdateCountdown()
{
   // 1. Static variable to store the state of the last update
   static int lastSeconds = -1;

   // 2. Calculate current seconds left
   // TimeTradeServer() is better for timers as it ticks even without new quotes
   datetime serverTime = TimeTradeServer();
   datetime barStart = iTime(_Symbol, _Period, 0);
   int periodSeconds = PeriodSeconds(_Period);
   int secondsLeft = (int)((barStart + periodSeconds) - serverTime);

   if (secondsLeft < 0)
      secondsLeft = 0;

   // 3. EXIT EARLY: If the second hasn't changed, don't waste CPU on UI/Redraw
   if (secondsLeft == lastSeconds)
      return;

   // Update the state for the next call
   lastSeconds = secondsLeft;

   // --- START UI UPDATES (Only runs once per second) ---

   string name = "UI_Countdown_Label";
   int h = secondsLeft / 3600;
   int m = (secondsLeft % 3600) / 60;
   int s = secondsLeft % 60;

   string clockStr = (_Period <= PERIOD_H1)
                         ? StringFormat("Next Bar in: %02d:%02d", m, s)
                         : StringFormat("Next Bar in: %02d:%02d:%02d", h, m, s);

   if (ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_TOP);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlue);
      ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
   }
   ObjectSetString(0, name, OBJPROP_TEXT, clockStr);

   int chartWidth = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, chartWidth / 2);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 20);

   //send to DLL
   clockStr = (_Period <= PERIOD_H1)
                  ? StringFormat("%02d:%02d", m, s)
                  : StringFormat("%02d:%02d:%02d", h, m, s);
   SendStringToDLL(clockStr, (int)CountdownUpdate);

   //also update account balance
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   string balanceStr = StringFormat("Bal: $%.2f", balance);
   SendStringToDLL(balanceStr, (int)AccountBalance);
   
   ChartRedraw(0);
}

string FetchStringFromDLL()
{
   ushort buffer[256];
   ArrayInitialize(buffer, 0);

   // This should no longer throw "undeclared identifier"
   MQLBridge::MQLBridge::GetLastMessage(buffer, 256);

   // Convert ushort array back to string
   string result = "";
   for (int i = 0; i < ArraySize(buffer); i++)
   {
      if (buffer[i] == 0)
         break; // Stop at null terminator
      result += CharToString(buffer[i]);
   }

   datetime t = iTime(_Symbol, _Period, 0);
   // MQLBridge::MQLBridge::UpdateHoverDetails(bar_index,o,c,h,l,(long)t);

   return result;
}

void SendStringToDLL(string msg, int id = 0)
{
   // Print("Sending message to DLL: ", msg);
   int len = StringLen(msg) + 1; // +1 for null terminator
   // Convert string to ushort array
   ushort buffer[];
   ArrayResize(buffer, len);

   StringToShortArray(msg, buffer);
   buffer[len - 1] = 0; // null terminator

   // Direct call - MQL5 handles the pointer conversion for you
   MQLBridge::MQLBridge::SendMessage(buffer, len, id);
}

//+------------------------------------------------------------------+
//| Check if we have reached the beginning of available history      |
//+------------------------------------------------------------------+
bool IsAtEndOfHistory(const string symbol, const ENUM_TIMEFRAMES timeframe, datetime target_date)
{
   datetime first_date = (datetime)SeriesInfoInteger(symbol, timeframe, SERIES_FIRSTDATE);

   // If the target we want to jump to is earlier than the first available date
   return (target_date <= first_date);
}

//+------------------------------------------------------------------+
//| Most Reliable: Get first bar of a specific date                  |
//+------------------------------------------------------------------+
datetime GetFirstBarTimeOfDay(datetime target_date)
{
   MqlDateTime dt;
   TimeToStruct(target_date, dt);
   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;

   datetime day_start = StructToTime(dt);
   datetime day_end = day_start + 86399; // 23:59:59

   // Get all bars for this day
   MqlRates rates[];
   ArraySetAsSeries(rates, false);

   int copied = CopyRates(_Symbol, PERIOD_H1, day_start, day_end, rates);

   if (copied > 0)
   {
      // Return the first bar's time
      return rates[0].time;
   }

   // No bars found - might be weekend or holiday
   return 0;
}

//+------------------------------------------------------------------+
//| Extract hour from datetime                                       |
//+------------------------------------------------------------------+
int GetHourFromDateTime(datetime dt)
{
   MqlDateTime mdt;
   TimeToStruct(dt, mdt);
   return mdt.hour;
}

//+------------------------------------------------------------------+
//| Complete solution: Get start hour with caching                   |
//+------------------------------------------------------------------+
// Global cache for start hours by date
struct DayStartCache
{
   datetime date;
   int start_hour;
};

DayStartCache _startHourCache[];

int GetCachedDayStartHour(datetime target_date)
{
   // Normalize to just the date (remove time)
   MqlDateTime dt;
   TimeToStruct(target_date, dt);
   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;
   datetime normalized_date = StructToTime(dt);

   // Check cache first
   for (int i = 0; i < ArraySize(_startHourCache); i++)
   {
      if (_startHourCache[i].date == normalized_date)
      {
         return _startHourCache[i].start_hour;
      }
   }

   // Not in cache, detect it
   datetime first_bar = GetFirstBarTimeOfDay(target_date);

   if (first_bar > 0)
   {
      int start_hour = GetHourFromDateTime(first_bar);

      // Add to cache
      int cache_size = ArraySize(_startHourCache);
      ArrayResize(_startHourCache, cache_size + 1);
      _startHourCache[cache_size].date = normalized_date;
      _startHourCache[cache_size].start_hour = start_hour;

      Print("Cached start hour for ", TimeToString(normalized_date, TIME_DATE), ": ", start_hour, ":00");
      return start_hour;
   }

   return -1; // Unable to determine
}

//+------------------------------------------------------------------+
//| Set the chart shift (space from right border)                    |
//+------------------------------------------------------------------+
void SetChartShift(int shift_percent)
{
   // shift_percent: 0-50 (percentage of chart width)
   // 0 = no shift, 50 = maximum shift (half the chart)
   Print("SetChartShift: ", shift_percent);
   ChartSetInteger(0, CHART_SHIFT, true);              // Enable shift
   ChartSetDouble(0, CHART_SHIFT_SIZE, shift_percent); // Set shift percentage

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Move the chart by specified number of bars                       |
//+------------------------------------------------------------------+
void MoveChartBars(string direction, int bars = 1)
{
   // Disable autoscroll to prevent chart from snapping back
   ChartSetInteger(0, CHART_AUTOSCROLL, false);

   int shift = 0;

   if (direction == "left")
   {
      shift = bars; // Positive = move left (into history)
   }
   else if (direction == "right")
   {
      shift = -bars; // Negative = move right (toward present)
   }
   else
   {
      Print("Invalid direction. Use 'left' or 'right'.");
      return;
   }

   if (!ChartNavigate(0, CHART_CURRENT_POS, shift))
   {
      Print("Failed to navigate chart. Error: ", GetLastError());
   }

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Get all deals in history for a time period                       |
//+------------------------------------------------------------------+
void GetTradeHistory(datetime from_date, datetime to_date)
{
   // Select history for the period
   if (!HistorySelect(from_date, to_date))
   {
      Print("Failed to select history");
      return;
   }

   int total_deals = HistoryDealsTotal();
   Print("Total deals in period: ", total_deals);

   string sTradeHistory = "";
   for (int i = 0; i < total_deals; i++)
   {
      ulong deal_ticket = HistoryDealGetTicket(i);

      if (deal_ticket > 0 && IsActualTrade(deal_ticket))
      {
         // Get deal properties
         long deal_type = HistoryDealGetInteger(deal_ticket, DEAL_TYPE);
         long deal_entry = HistoryDealGetInteger(deal_ticket, DEAL_ENTRY);
         double deal_profit = HistoryDealGetDouble(deal_ticket, DEAL_PROFIT);
         double deal_volume = HistoryDealGetDouble(deal_ticket, DEAL_VOLUME);
         double deal_price = HistoryDealGetDouble(deal_ticket, DEAL_PRICE);
         datetime deal_time = (datetime)HistoryDealGetInteger(deal_ticket, DEAL_TIME);
         string deal_symbol = HistoryDealGetString(deal_ticket, DEAL_SYMBOL);
         string deal_comment = HistoryDealGetString(deal_ticket, DEAL_COMMENT);

         sTradeHistory += StringFormat("%lld,%s,%s,%.2f,%.5f,%.2f,%s,%s\n",
                                       deal_ticket,
                                       deal_symbol,
                                       GetDealTypeString(deal_type),
                                       deal_volume,
                                       deal_price,
                                       deal_profit,
                                       TimeToString(deal_time, TIME_DATE | TIME_MINUTES | TIME_SECONDS),
                                       deal_comment);

         PrintFormat("Deal #%lld: %s %s %.2f lots at %.5f, Profit: %.2f, Time: %s",
                     deal_ticket,
                     deal_symbol,
                     GetDealTypeString(deal_type),
                     deal_volume,
                     deal_price,
                     deal_profit,
                     TimeToString(deal_time));
      }
   }

   SendStringToDLL(sTradeHistory, 0);
}

string GetDealTypeString(long deal_type)
{
   switch (deal_type)
   {
   case DEAL_TYPE_BUY:
      return "Buy";
   case DEAL_TYPE_SELL:
      return "Sell";
   case DEAL_TYPE_BALANCE:
      return "Balance";
   case DEAL_TYPE_CREDIT:
      return "Credit";
   case DEAL_TYPE_CHARGE:
      return "Charge";
   case DEAL_TYPE_CORRECTION:
      return "Correction";
   case DEAL_TYPE_BONUS:
      return "Bonus";
   case DEAL_TYPE_COMMISSION:
      return "Commission";
   case DEAL_TYPE_COMMISSION_DAILY:
      return "Daily Commission";
   case DEAL_TYPE_COMMISSION_MONTHLY:
      return "Monthly Commission";
   case DEAL_TYPE_COMMISSION_AGENT_DAILY:
      return "Agent Daily Commission";
   case DEAL_TYPE_COMMISSION_AGENT_MONTHLY:
      return "Agent Monthly Commission";
   case DEAL_TYPE_INTEREST:
      return "Interest";
   case DEAL_TYPE_BUY_CANCELED:
      return "Buy Canceled";
   case DEAL_TYPE_SELL_CANCELED:
      return "Sell Canceled";
   default:
      return "Unknown";
   }
}

//+------------------------------------------------------------------+
//| Simple function to check if deal is an actual trade              |
//+------------------------------------------------------------------+
bool IsActualTrade(ulong deal_ticket)
{
   long deal_entry = HistoryDealGetInteger(deal_ticket, DEAL_ENTRY);
   long deal_type = HistoryDealGetInteger(deal_ticket, DEAL_TYPE);

   // Must be entry/exit AND must be buy/sell
   return (deal_entry == DEAL_ENTRY_IN || deal_entry == DEAL_ENTRY_OUT) &&
          (deal_type == DEAL_TYPE_BUY || deal_type == DEAL_TYPE_SELL);
}

//+------------------------------------------------------------------+
//| Auto Trade Function with TP/SL in Pips                          |
//+------------------------------------------------------------------+
// #include <Trade/Trade.mqh>

// Global trade object (declared on top)
// CTrade trade;

// Enum for trade direction
enum ENUM_TRADE_DIRECTION
{
   TRADE_BUY,
   TRADE_SELL
};

//+------------------------------------------------------------------+
//| Main auto trade function                                         |
//+------------------------------------------------------------------+
bool AutoTrade(ENUM_TRADE_DIRECTION direction, 
               double lots, 
               int tp_pips, 
               int sl_pips,
               string comment = "")
{
   // Get current price
   double price = 0;
   double sl_price = 0;
   double tp_price = 0;
   
   // Calculate point value for pips
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   
   // Adjust for 5-digit/3-digit brokers
   double pip_value = point;
   // if (digits == 5 || digits == 3)
   //    pip_value = point * 10;
   
   // Get prices based on direction
   if (direction == TRADE_BUY)
   {
      price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      
      // Calculate SL and TP for BUY
      if (sl_pips > 0)
         sl_price = price - (sl_pips * pip_value);
      
      if (tp_pips > 0)
         tp_price = price + (tp_pips * pip_value);
   }
   else // SELL
   {
      price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      // Calculate SL and TP for SELL
      if (sl_pips > 0)
         sl_price = price + (sl_pips * pip_value);
      
      if (tp_pips > 0)
         tp_price = price - (tp_pips * pip_value);
   }
   
   // Normalize prices
   price = NormalizeDouble(price, digits);
   sl_price = NormalizeDouble(sl_price, digits);
   tp_price = NormalizeDouble(tp_price, digits);
   
   // Validate lot size
   double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lot_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   if (lots < min_lot)
   {
      Print("Lot size too small. Minimum: ", min_lot);
      return false;
   }
   
   if (lots > max_lot)
   {
      Print("Lot size too large. Maximum: ", max_lot);
      return false;
   }
   
   // Normalize lot size to step
   lots = NormalizeDouble(lots, 2);
   
   // Execute the trade
   bool result = false;
   
   if (direction == TRADE_BUY)
   {
      result = trade.Buy(lots, _Symbol, price, sl_price, tp_price, comment);
   }
   else
   {
      result = trade.Sell(lots, _Symbol, price, sl_price, tp_price, comment);
   }
   
   // Check result
   if (result)
   {
      PrintFormat("Trade executed successfully: %s %.2f lots at %.5f, SL: %.5f, TP: %.5f",
                  direction == TRADE_BUY ? "BUY" : "SELL",
                  lots, price, sl_price, tp_price);
      
      // Get ticket number
      ulong ticket = trade.ResultOrder();
      Print("Order ticket: ", ticket);
   }
   else
   {
      Print("Trade failed. Error: ", GetLastError());
      Print("Error description: ", trade.ResultRetcodeDescription());
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| Get correct pip value for any symbol                             |
//+------------------------------------------------------------------+
double GetPipValue(string symbol)
{
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   
   // For metals (Gold, Silver)
   if (StringFind(symbol, "XAU") >= 0 || 
       StringFind(symbol, "XAG") >= 0 || 
       StringFind(symbol, "GOLD") >= 0 || 
       StringFind(symbol, "SILVER") >= 0)
   {
      // Gold/Silver: 1 pip = 0.10 (regardless of 2 or 3 decimals)
      return 0.10;
   }
   
   // For JPY pairs
   if (StringFind(symbol, "JPY") >= 0)
   {
      if (digits == 3)
         return 0.01;  // 3-digit JPY: 1 pip = 0.01
      else
         return 0.01;  // 2-digit JPY: 1 pip = 0.01
   }
   
   // For standard forex pairs
   if (digits == 5)
      return 0.0001;  // 5-digit: 1 pip = 0.0001
   else if (digits == 4)
      return 0.0001;  // 4-digit: 1 pip = 0.0001
   else if (digits == 3)
      return 0.01;    // 3-digit: 1 pip = 0.01
   else if (digits == 2)
      return 0.01;    // 2-digit: 1 pip = 0.01
   
   // Fallback
   return point * 10;
}

//+------------------------------------------------------------------+
//| Auto trade with EXACT pip count enforcement                      |
//+------------------------------------------------------------------+
bool AutoTradeExact(ENUM_TRADE_DIRECTION direction, 
                    double lots, 
                    int tp_pips, 
                    int sl_pips,
                    string comment = "")
{
   double price = 0;
   double sl_price = 0;
   double tp_price = 0;
   
   double pip_value = GetPipValue(_Symbol);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   
   // Get entry price
   if (direction == TRADE_BUY)
      price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   else
      price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   price = NormalizeDouble(price, digits);
   
   // Calculate TP and SL with EXACT pip distances
   if (direction == TRADE_BUY)
   {
      if (sl_pips > 0)
         sl_price = NormalizeDouble(price - (sl_pips * pip_value), digits);
      
      if (tp_pips > 0)
         tp_price = NormalizeDouble(price + (tp_pips * pip_value), digits);
   }
   else
   {
      if (sl_pips > 0)
         sl_price = NormalizeDouble(price + (sl_pips * pip_value), digits);
      
      if (tp_pips > 0)
         tp_price = NormalizeDouble(price - (tp_pips * pip_value), digits);
   }
   
   // Verify and log
   Print("=== EXACT PIP CALCULATION ===");
   PrintFormat("Pip Value: %.5f", pip_value);
   PrintFormat("Entry Price: %.5f", price);
   
   if (tp_pips > 0)
   {
      double tp_distance = MathAbs(tp_price - price);
      double tp_pips_calculated = tp_distance / pip_value;
      PrintFormat("TP: %.5f | Distance: %.5f | Pips: %.2f (requested: %d)", 
                  tp_price, tp_distance, tp_pips_calculated, tp_pips);
   }
   
   if (sl_pips > 0)
   {
      double sl_distance = MathAbs(price - sl_price);
      double sl_pips_calculated = sl_distance / pip_value;
      PrintFormat("SL: %.5f | Distance: %.5f | Pips: %.2f (requested: %d)", 
                  sl_price, sl_distance, sl_pips_calculated, sl_pips);
   }
   
   // Execute
   bool result = false;
   
   if (direction == TRADE_BUY)
      result = trade.Buy(lots, _Symbol, price, sl_price, tp_price, comment);
   else
      result = trade.Sell(lots, _Symbol, price, sl_price, tp_price, comment);
   
   return result;
}

//+------------------------------------------------------------------+
//| Check if trading is allowed                                      |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
{
   // Check if AutoTrading is enabled in terminal
   if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
   {
      Print("AutoTrading is disabled in terminal");
      return false;
   }
   
   // Check if trading is allowed for this EA
   if (!MQLInfoInteger(MQL_TRADE_ALLOWED))
   {
      Print("Trading is not allowed for this EA. Check 'Allow live trading' in properties");
      return false;
   }
   
   // Check if account allows trading
   if (!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
   {
      Print("Trading is forbidden for this account");
      return false;
   }
   
   // Check if trading is allowed for the symbol
   if (!SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE))
   {
      Print("Trading is disabled for ", _Symbol);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Advanced auto trade with price validation                        |
//+------------------------------------------------------------------+
bool AutoTradeAdvanced(ENUM_TRADE_DIRECTION direction,
                       double lots,
                       int tp_pips,
                       int sl_pips,
                       string comment = "",
                       ulong magic = 0,
                       ulong deviation = 10)
{
   // Set magic number and deviation
   if (magic > 0)
      trade.SetExpertMagicNumber(magic);
   
   trade.SetDeviationInPoints(deviation);
   
   // Validate trading conditions
   if (!IsTradeAllowed())
   {
      Print("Trading not allowed");
      return false;
   }
   
   // Check if market is open
   if (!SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE))
   {
      Print("Market is closed for ", _Symbol);
      return false;
   }
   
   // Execute trade
   return AutoTrade(direction, lots, tp_pips, sl_pips, comment);
}

//+------------------------------------------------------------------+
//| Auto trade with percentage-based position sizing                 |
//+------------------------------------------------------------------+
bool AutoTradeWithRisk(ENUM_TRADE_DIRECTION direction,
                       double risk_percent,
                       int tp_pips,
                       int sl_pips,
                       string comment = "")
{
   if (sl_pips <= 0)
   {
      Print("SL pips must be greater than 0 for risk-based position sizing");
      return false;
   }
   
   // Calculate lot size based on risk
   double lots = CalculateLotSize(risk_percent, sl_pips);
   
   if (lots <= 0)
   {
      Print("Calculated lot size is invalid: ", lots);
      return false;
   }
   
   Print("Calculated lot size based on ", risk_percent, "% risk: ", lots);
   
   return AutoTrade(direction, lots, tp_pips, sl_pips, comment);
}

//+------------------------------------------------------------------+
//| Calculate lot size based on risk percentage                      |
//+------------------------------------------------------------------+
double CalculateLotSize(double risk_percent, int sl_pips)
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double risk_amount = balance * (risk_percent / 100.0);
   
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   
   // Adjust for 5-digit/3-digit brokers
   double pip_value = point;
   if (digits == 5 || digits == 3)
      pip_value = point * 10;
   
   double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   
   // Calculate lot size
   double sl_distance = sl_pips * pip_value;
   double lots = risk_amount / (sl_distance / tick_size * tick_value);
   
   // Normalize to lot step
   double lot_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   lots = MathFloor(lots / lot_step) * lot_step;
   
   // Ensure within limits
   double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   
   if (lots < min_lot) lots = min_lot;
   if (lots > max_lot) lots = max_lot;
   
   return NormalizeDouble(lots, 2);
}

//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
int CloseAllPositions(string symbol = "")
{
   int closed = 0;
   
   for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      
      if (ticket > 0)
      {
         string pos_symbol = PositionGetString(POSITION_SYMBOL);
         
         // Filter by symbol if specified
         if (symbol != "" && pos_symbol != symbol)
            continue;
         
         if (trade.PositionClose(ticket))
         {
            Print("Position closed: ", ticket);
            closed++;
         }
         else
         {
            Print("Failed to close position: ", ticket, " Error: ", GetLastError());
         }
      }
   }
   
   return closed;
}

//+------------------------------------------------------------------+
//| Modify existing position TP/SL                                   |
//+------------------------------------------------------------------+
bool ModifyPosition(ulong ticket, int tp_pips, int sl_pips)
{
   if (!PositionSelectByTicket(ticket))
   {
      Print("Position not found: ", ticket);
      return false;
   }
   
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   
   double pip_value = point;
   if (digits == 5 || digits == 3)
      pip_value = point * 10;
   
   double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
   long type = PositionGetInteger(POSITION_TYPE);
   
   double sl_price = 0;
   double tp_price = 0;
   
   if (type == POSITION_TYPE_BUY)
   {
      if (sl_pips > 0)
         sl_price = open_price - (sl_pips * pip_value);
      if (tp_pips > 0)
         tp_price = open_price + (tp_pips * pip_value);
   }
   else // SELL
   {
      if (sl_pips > 0)
         sl_price = open_price + (sl_pips * pip_value);
      if (tp_pips > 0)
         tp_price = open_price - (tp_pips * pip_value);
   }
   
   sl_price = NormalizeDouble(sl_price, digits);
   tp_price = NormalizeDouble(tp_price, digits);
   
   return trade.PositionModify(ticket, sl_price, tp_price);
}

//+------------------------------------------------------------------+
//| Get current account balance                                      |
//+------------------------------------------------------------------+
double GetAccountBalance()
{
   return AccountInfoDouble(ACCOUNT_BALANCE);
}


#import "MQLBridge.dll"
#import

#import "user32.dll"
long WindowFromPoint(int x, int y);
long GetForegroundWindow();
#import