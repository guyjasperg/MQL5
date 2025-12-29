//+------------------------------------------------------------------+
//|                                                  LA_Backtest.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Guy Jasper Gonzaga"
#property link      "https://www.mql5.com"
#property version   "1.00"

//--- Input parameters
input int DaysToShow = 5;           // Number of days to show lines for
input color LineColor = clrBlue;    // Color of the horizontal lines
input int LineWidth = 1;            // Width of the lines
input ENUM_LINE_STYLE LineStyle = STYLE_SOLID; // Style of the lines
input bool EnableDebugLogs = false;  // Enable detailed debug logging
input bool EnableTrading = false;   // Enable automatic trading
input double LotSize = 0.1;         // Trade lot size
input int StopLoss = 50;            // Stop loss in points
input int TakeProfit = 100;         // Take profit in points
input bool ClearAllObjectsOnStart = false; // Clear all chart objects when EA starts

//--- Input separator
input string Separator1 = "=================="; // --- Drawing Settings ---
input int PanelWidth = 400;        // Width of the control panel
input int PanelHeight = 200;       // Height of the control panel

//--- Global variables
string line_prefix = "LA_HighLowClose_";  // Prefix for line object names
#include <Trade/Trade.mqh>          // Include trading library
#include "../../Include/MyPanel.mqh"  // Path relative to MQL5\Include

CTrade trade;                       // Trade object
CMyPanel MyUI;

//+------------------------------------------------------------------+
//| Debug print function                                            |
//+------------------------------------------------------------------+
void DebugPrint(string message)
{
   if(EnableDebugLogs)
      Print("[DEBUG] ", message);
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  if(!MyUI.Create(0, "LA Backtest", 0, 350, 20, PanelWidth, PanelHeight))
    return INIT_FAILED;
  
  MyUI.txtS1Days.Text(IntegerToString(DaysToShow));

  MyUI.Run();
  

  // Draw_S1_Lines(D'2025.12.29', 10); // Example date and previous days

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
   Print("Daily High Close Lines EA deinitialized");
   MyUI.Destroy(reason);
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
  // Pass all chart events to the UI class
  if(id == CHARTEVENT_OBJECT_CLICK)
  {
    if(sparam == "btnPrev")
    {
      datetime currentDate = StringToTime(MyUI.txtDate.Text());
      datetime previousDate = GetPreviousTradingDay(currentDate);
      MyUI.txtDate.Text( TimeToString(previousDate, TIME_DATE));
      RemoveAllLines();
      Draw_S1_Lines(previousDate, DaysToShow);
    }
    else if(sparam == "btnNext")
    {
      datetime currentDate = StringToTime(MyUI.txtDate.Text());
      datetime nextDate = GetNextTradingDay(currentDate);
      MyUI.txtDate.Text( TimeToString(nextDate, TIME_DATE));
      RemoveAllLines();
      Draw_S1_Lines(nextDate, DaysToShow);
    }
    else if(sparam == "btnSetDate")
    {
      datetime setDate = StringToTime(MyUI.txtDate.Text());
      RemoveAllLines();
      Draw_S1_Lines(setDate, DaysToShow);
    }
    // Print("Chart event: CLICK at X=" + IntegerToString(lparam) + ", Y=" + IntegerToString((long)dparam) + ", Object: " + sparam );
  }
  else if(id == CHARTEVENT_OBJECT_CHANGE)
  {
    Print("Chart event: OBJECT CHANGE - Object: " + sparam);
  }
  else
  {
    //Print("Chart event: ID=",id, " lparam=", lparam, ", dparam=",dparam, ", sparam=",sparam);
  }
  
  
  MyUI.ChartEvent(id, lparam, dparam, sparam);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   
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
   for(int i = total_objects - 1; i >= 0; i--)
   {
      string obj_name = ObjectName(0, i);
      
      // Check if object name starts with our prefix
      if(StringFind(obj_name, line_prefix) == 0)
      {
         DebugPrint("Removing object: " + obj_name);
         if(ObjectDelete(0, obj_name))
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
   Print("+GetBarsByDate(): Date = ", TimeToString(date, TIME_DATE));

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

   if(copied <= 0)
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
   dt_today.hour = 0; dt_today.min = 0; dt_today.sec = 0;
   datetime today_normalized = StructToTime(dt_today);

   // Only look for the "next day bar" if the target date is in the past
   if(start_of_day < today_normalized)
   {
      // include bar for next day 00:00 if exists
      MqlRates next_day_bar[];
      datetime next_day = AddOneDay(start_of_day);
      int tries = 0, next_copied = 0;

      while(tries < 5 && next_copied == 0)
      {
         Print("Checking for next day bar on date: ", TimeToString(next_day, TIME_DATE));
         next_copied = CopyRates(symbol, timeframe, next_day, next_day + 3601, next_day_bar);
         
         if(next_copied > 0)
         {
            Print("Found next day bar for date: ", TimeToString(next_day, TIME_DATE));
            
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
      Print("Target date is today. Skipping next-day bar check.");
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
   if(size == 0)
   {
      Print("PrintBars: Array is empty.");
      return;
   }

   Print("--- Debug Print: Bars Found ---");
   PrintFormat("%-5s | %-20s | %-8s | %-8s | %-8s | %-8s", 
               "Index", "Time", "Open", "High", "Low", "Close");
   Print("------------------------------------------------------------------");

   for(int i = 0; i < size; i++)
   {
      string timeStr = TimeToString(rates[i].time, TIME_DATE|TIME_MINUTES|TIME_SECONDS);
      
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
   Print("+GetHighestBodyPrice()");
   int size = ArraySize(rates);
   if(size <= 0) return 0.0;

   out_index = 0;
   // Initial comparison value for the first bar
   double highest = (rates[0].close >= rates[0].open) ? rates[0].close : rates[0].open;


   for(int i = 1; i < size; i++)
   {
      // If bullish (or doji), use Close. If bearish, use Open.
      double currentBodyTop = (rates[i].close >= rates[i].open) ? rates[i].close : rates[i].open;

      if(currentBodyTop > highest)
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
   if(size <= 0) return 0.0;

   out_index = 0;
   // Initial comparison value for the first bar
   double lowest = (rates[0].close <= rates[0].open) ? rates[0].close : rates[0].open;

   for(int i = 1; i < size; i++)
   {
      // If bullish (or doji), use Close. If bearish, use Open.
      double currentBodyLow = (rates[i].close <= rates[i].open) ? rates[i].close : rates[i].open;

      if(currentBodyLow < lowest)
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
   if(size <= 0) return 0.0;

   int out_index = 0;
   // Initial comparison value for the first bar
   double lowest = (rates[0].close <= rates[0].open) ? rates[0].close : rates[0].open;

   for(int i = 1; i < size; i++)
   {
      // If bullish (or doji), use Close. If bearish, use Open.
      double currentBodyLow = (rates[i].close <= rates[i].open) ? rates[i].close : rates[i].open;

      if(currentBodyLow < lowest)
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
   Print("+GetHighestBodyPrice()");
   int size = GetBarsByDate(_Symbol, PERIOD_H1, targetdate, rates);
   if(size <= 0) return 0.0;

   // Initial comparison value for the first bar
   double highest = (rates[0].close >= rates[0].open) ? rates[0].close : rates[0].open;

   for(int i = 1; i < size; i++)
   {
      // If bullish (or doji), use Close. If bearish, use Open.
      double currentBodyTop = (rates[i].close >= rates[i].open) ? rates[i].close : rates[i].open;

      if(currentBodyTop > highest)
      {
         highest = currentBodyTop;
      }
   }
   return highest;
}


void Draw_S1_Lines(datetime targetDate, int prevDays)
{
   MqlRates dayBars[];
   
   //Draw vertical line at start of the target date
   DrawVerticalLine(targetDate);

   //S1 lines for target date will start from previous day
   datetime prevday = SubtractOneDay(targetDate);
   int total = GetBarsByDate(_Symbol, PERIOD_H1, prevday, dayBars);
   
   while(total == 0)
   {
      //no bars found, go back one more day
      prevday = SubtractOneDay(prevday);
      total = GetBarsByDate(_Symbol, PERIOD_H1, prevday, dayBars);
   }

   int index = 0;
   double price = 0.0;
   string desc = "";
  
   if(total > 0)
   {
      Print("Found ", total, " bars.");
      // dayBars[0] will be the 23:45 bar (if using ArraySetAsSeries)
      // dayBars[total-1] will be the 00:00 bar
      //PrintBars(dayBars);
      
      price = GetHighestBodyPrice(dayBars, index);
      desc = "High_" + TimeToString(prevday, TIME_DATE);
      Draw_Line(price, desc, 0);
      
      price = GetLowestBodyPrice(dayBars, index);
      desc = "Low_" + TimeToString(prevday, TIME_DATE);
      Draw_Line(price, desc, 0);

      DrawPeriodDetails(prevday); // Place label slightly above the low line
   }

   if(prevDays > 0)
   {
      //raw S1 lines from n previous days
      int count = prevDays;
      
      datetime currentDay = prevday;
      while(count > 0)
      {
         //get prvious day date
         datetime prevDay = SubtractOneDay(currentDay);
         total = GetBarsByDate(_Symbol, PERIOD_H1, prevDay, dayBars);
         if(total > 0)
         {
            //we have bars, draw S1 lines
            price = GetHighestBodyPrice(dayBars, index);
            desc = "High_" + TimeToString(prevDay, TIME_DATE);
            Draw_Line(price, desc, 1);
            
            price = GetLowestBodyPrice(dayBars, index);
            desc = "Low_" + TimeToString(prevDay, TIME_DATE);
            Draw_Line(price, desc, 1);
         
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
   if(ObjectCreate(0, line_name, OBJ_HLINE, 0, 0, price))
   {
      // Set line properties
      if(style == 0)
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
   
   // Normalize to start of day (00:00)
   MqlDateTime dt;
   TimeToStruct(time, dt);
   dt.hour = 1; dt.min = 0; dt.sec = 0;
   datetime startOfDay = StructToTime(dt);

   string name = line_prefix + "_DayStart_" + TimeToString(startOfDay, TIME_DATE);

   // 1. Try to create the object (Chart ID 0 is the current chart)
   // OBJ_VLINE only requires 'time' (price is ignored)
   if(!ObjectCreate(0, name, OBJ_VLINE, 0, startOfDay, 0))
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
   
   // 4. Force a chart refresh to show the change immediately
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Place a text label in the middle (12:00) of a specific day       |
//+------------------------------------------------------------------+
void DrawPeriodDetails(const datetime targetdate)
{
   // 1. Normalize to the start of the given day
   MqlDateTime dt;
   TimeToStruct(targetdate, dt);
   dt.hour = 0; dt.min = 0; dt.sec = 0;
   
   // 2. Calculate the middle of the day (12:00:00)
   datetime middleTime = StructToTime(dt) + 43200; 
   string name = line_prefix + "_PDR_" + TimeToString(targetdate, TIME_DATE);

   //GET PDR of targetdate
   MqlRates rates[];
   int bars = GetBarsByDate(_Symbol,PERIOD_H1,targetdate, rates);

   if(bars == 0)
   {
      return;
   }

   int pdr_rate = (GetHighestBodyPrice(rates, bars) - GetLowestBodyPrice(rates, bars)) * 100;

   //Draw PDR below lowest price
   // double lowprice = GetLowestBodyPrice(rates, bars);
   double lowprice = GetLowestBodyPriceByDate(targetdate);

   // Write PDR label
   DrawPeriodLabel(targetdate, "PDR: " + IntegerToString(pdr_rate), lowprice - 300*_Point);

   ChartRedraw(0);
}

void DrawPeriodLabel(const datetime targetdate, const string text, double price)
{
   // 1. Normalize to the start of the given day
   MqlDateTime dt;
   TimeToStruct(targetdate, dt);
   dt.hour = 0; dt.min = 0; dt.sec = 0;
   
   // 2. Calculate the middle of the day (12:00:00)
   datetime middleTime = StructToTime(dt) + 43200; 

   string name = line_prefix + "_Label_" + TimeToString(targetdate, TIME_DATE);

   // 3. Create or Move the Text Object
   if(!ObjectCreate(0, name, OBJ_TEXT, 0, middleTime, price))
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
   
   while(total == 0)
   {
      //no bars found, go back one more day
      prev_day = SubtractOneDay(prev_day);
      total = GetBarsByDate(_Symbol, PERIOD_D1, prev_day, rates);
   }
   
   return prev_day;
}

datetime GetNextTradingDay(datetime source_time)
{
  datetime next_day = AddOneDay(source_time);
  datetime current_server_time = TimeCurrent();
  
  if(next_day > current_server_time)
  {
    return source_time;
  }
  
  MqlRates rates[];
  int total = GetBarsByDate(_Symbol, PERIOD_D1, next_day, rates);
  
  while(total == 0)
  {
    //no bars found, go forward one more day
    next_day = AddOneDay(next_day);
    
    if(next_day > current_server_time)
    {
      return source_time;
    }
    
    total = GetBarsByDate(_Symbol, PERIOD_D1, next_day, rates);
  }
  
  return next_day;
}