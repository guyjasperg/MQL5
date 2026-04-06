//+------------------------------------------------------------------+
//|                                             LA_Backtest_Play.mq5 |
//|                                               Guy Jasper Gonzaga |
//|                                                 https://mql5.com |
//| 28.01.2026 - Initial release                                     |
//+------------------------------------------------------------------+
#property copyright "Guy Jasper Gonzaga"
#property link "https://mql5.com"
#property version "1.00"

color LineColor = clrBlue;               // Color of the horizontal lines
int LineWidth = 1;                       // Width of the lines
ENUM_LINE_STYLE LineStyle = STYLE_SOLID; // Style of the lines

string line_prefix = "LA_Backtest_"; // Prefix for line object names
bool EnableDebugLogs = true;             // Enable debug logs
bool TrackMouse = true;              // Track mouse movements on chart

// Move these from #define to global variables
string TOOLTIP_RECT_NAME = "LA_Backtest_UI_Tooltip_Box";
string TOOLTIP_TEXT_NAME = "LA_Backtest_UI_Tooltip_Txt";
string TooltipRows[] = {"UI_Title", "UI_Open", "UI_Close", "UI_High", "UI_Low"};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
{
   //---
   MqlRates my_rates[];
   // If timeframe is H1, you get today's bars.
   // If timeframe is H4, you get this week's bars.
   int total = GetBarsByTimeframeRange2(_Symbol, _Period, SubtractOneDay(TimeCurrent()), my_rates);
   //---
   for (int i = 0; i < total; i++)
   {
      if (i == 0 || i == total )
      {
         DrawVerticalLine(my_rates[i].time);
      }
      PrintFormat("Bar %d: Time=%s, Open=%.5f, High=%.5f, Low=%.5f, Close=%.5f, Volume=%lld",
                  i, TimeToString(my_rates[i].time), my_rates[i].open, my_rates[i].high,
                  my_rates[i].low, my_rates[i].close, my_rates[i].tick_volume);
   }
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   EventSetMillisecondTimer(100);
   return (INIT_SUCCEEDED);
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if (id == CHARTEVENT_MOUSE_MOVE)
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
         // If we are still over the same bar, exit immediately

         if (bar_start_time == last_processed_bar_time)
         {
            // MyUI.ChartEvent(id, lparam, dparam, sparam);
            return;
         }

         // Update the state for the next move
         last_processed_bar_time = bar_start_time;
         // ---------------------

         MqlRates rates[];
         if(CopyRates(_Symbol, _Period, bar_index, 1, rates) > 0)
         {
            DrawTooltipOnNextBar(rates[0]);
            DrawMouseMarker(rates[0]);
         }

         // 4. Heavy logic only runs when the mouse moves to a NEW bar
         // MqlRates bar;
         // if (GetBarUnderMouse(x, y, bar))
         // {
         //    if (TrackMouse)
         //    {
         //       DrawMouseMarker(bar);
         //    }
         //    else
         //    {
         //       RemoveMouseMarker();
         //       ChartRedraw(0);
         //    }
         // }
      }
   }
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
{
   // 1. Explicitly delete the known UI elements first
   if(ObjectFind(0, TOOLTIP_RECT_NAME) >= 0) ObjectDelete(0, TOOLTIP_RECT_NAME);
   if(ObjectFind(0, TOOLTIP_TEXT_NAME) >= 0) ObjectDelete(0, TOOLTIP_TEXT_NAME);
   
   for(int i = 0; i < 5; i++) {
      if(ObjectFind(0, TooltipRows[i]) >= 0) ObjectDelete(0, TooltipRows[i]);
   }
   
   RemoveAllLines2();
   RemoveMouseMarker();
   
   ChartSetInteger(0, CHART_AUTOSCROLL, true);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick()
{
   //---
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   UpdateCountdown();
   // CheckUIEvents();
}

void CheckUIEvents()
{
   //GenericEvent evt;

   // Process all pending events
   // while(GetNextEvent(evt))
   // {
   //    ProcessUIEvent(evt);
   // }
   // MQLBridge::MQLBridge::GenericEvent evt;
   
   // while(UIController::GetNextEvent(evt))
   // {
   //    string message = ShortArrayToString(evt.StringValue);
      
   //    PrintFormat("ID: %d | Long: %lld | Double: %.2f | String: %s", 
   //                evt.CommandID, evt.LongValue, evt.DoubleValue, message);
                  
   //    ProcessGenericEvent(evt);
   // }
}


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Get bars based on timeframe grouping                             |
//| H1 -> Full Day, H4 -> Full Week, D1 -> Full Month                |
//+------------------------------------------------------------------+
int GetBarsByTimeframeRange(const string symbol,
                            const ENUM_TIMEFRAMES timeframe,
                            const datetime date,
                            MqlRates &rates[])
{
   MqlDateTime dt_struct;
   TimeToStruct(date, dt_struct);

   datetime start_range;
   datetime end_range;

   // 1. Determine boundaries based on logic requested
   switch (timeframe)
   {
   case PERIOD_H1:
      // Start of Day to End of Day
      dt_struct.hour = 0;
      dt_struct.min = 0;
      dt_struct.sec = 0;
      start_range = StructToTime(dt_struct);
      end_range = start_range + 86399;
      break;

   case PERIOD_H4:
      // Start of Week to End of Week (Sunday to Saturday)
      // dt_struct.day_of_week: 0=Sunday, 1=Monday...
      start_range = date - (dt_struct.day_of_week * 86400);
      TimeToStruct(start_range, dt_struct);
      dt_struct.hour = 0;
      dt_struct.min = 0;
      dt_struct.sec = 0;
      start_range = StructToTime(dt_struct);
      end_range = start_range + (7 * 86400) - 1;
      break;

   case PERIOD_D1:
      // Start of Month to End of Month
      dt_struct.day = 1;
      dt_struct.hour = 0;
      dt_struct.min = 0;
      dt_struct.sec = 0;
      start_range = StructToTime(dt_struct);

      // Move to next month, then subtract 1 second
      if (++dt_struct.mon > 12)
      {
         dt_struct.mon = 1;
         dt_struct.year++;
      }
      end_range = StructToTime(dt_struct) - 1;
      break;

   default:
      // Fallback: Just return the specific day if timeframe doesn't match
      dt_struct.hour = 0;
      dt_struct.min = 0;
      dt_struct.sec = 0;
      start_range = StructToTime(dt_struct);
      end_range = start_range + 86399;
      break;
   }

   // 2. Prepare the array
   ArrayFree(rates);
   ArraySetAsSeries(rates, false);

   // 3. Request data
   ResetLastError();
   int copied = CopyRates(symbol, timeframe, start_range, end_range, rates);

   if (copied <= 0)
   {
      PrintFormat("No bars found for %s on TF %s. Start: %s, Error: %d",
                  symbol, EnumToString(timeframe), TimeToString(start_range), GetLastError());
      return 0;
   }

   // 4. Next-day/Next-period bridge logic
   // If the target range is in the past, we grab the first bar of the NEXT period
   // to show the transition (as per your original code logic)
   datetime current_server_time = TimeCurrent();
   if (end_range < current_server_time)
   {
      MqlRates next_period_bar[];
      // Look for the very next available bar immediately after our range
      int next_copied = CopyRates(symbol, timeframe, end_range + 1, 1, next_period_bar);

      if (next_copied > 0)
      {
         int original_size = ArraySize(rates);
         ArrayResize(rates, original_size + 1);
         rates[original_size] = next_period_bar[0];
         copied += 1;
      }
   }

   return copied;
}

int GetBarsByTimeframeRange2(const string symbol,
                            const ENUM_TIMEFRAMES timeframe,
                            const datetime date,
                            MqlRates &rates[])
{
   MqlDateTime dt;
   TimeToStruct(date, dt);
   datetime start_range, end_range;

   // 1. Calculate the theoretical time boundaries
   switch(timeframe)
   {
      case PERIOD_H1: // Range: One Day
         dt.hour=0; dt.min=0; dt.sec=0;
         start_range = StructToTime(dt);
         end_range   = start_range + 86400; // Start of tomorrow
         break;

      case PERIOD_H4: // Range: One Week
         start_range = date - (dt.day_of_week * 86400);
         TimeToStruct(start_range, dt);
         dt.hour=0; dt.min=0; dt.sec=0;
         start_range = StructToTime(dt);
         end_range   = start_range + (7 * 86400); // Start of next week
         break;

      case PERIOD_D1: // Range: One Month
         dt.day=1; dt.hour=0; dt.min=0; dt.sec=0;
         start_range = StructToTime(dt);
         if(++dt.mon > 12) { dt.mon=1; dt.year++; }
         end_range   = StructToTime(dt); // Start of next month
         break;

      default:
         dt.hour=0; dt.min=0; dt.sec=0;
         start_range = StructToTime(dt);
         end_range   = start_range + 86400;
         break;
   }

   // 2. Convert Time to Indices (The "Developer" Way)
   // We find where the period starts and where the NEXT period starts
   int start_idx = iBarShift(symbol, timeframe, start_range, false);
   int end_idx   = iBarShift(symbol, timeframe, end_range, false);

   // 3. Logic: If we want the "Bridge Bar", we include the bar at end_idx.
   // In TimeSeries: StartIndex (Older) > EndIndex (Newer).
   // To get the bar AFTER the range, we just ensure our count covers it.
   int count = start_idx - end_idx + 1; 

   if(count <= 0) return 0;

   // 4. Single optimized data request
   ArrayFree(rates);
   ArraySetAsSeries(rates, false); 
   
   ResetLastError();
   // Copying from end_idx (the newer end) for 'count' bars back into the past
   int copied = CopyRates(symbol, timeframe, end_idx, count, rates);

   if(copied <= 0)
   {
      PrintFormat("History Gap: %s %s at %s. Error: %d", 
                  symbol, EnumToString(timeframe), TimeToString(start_range), GetLastError());
   }

   return copied;
}

//+------------------------------------------------------------------+
//| Debug print function                                            |
//+------------------------------------------------------------------+
void DebugPrint(string message)
{
   if (EnableDebugLogs)
      Print("[DEBUG] ", message);
}

//+------------------------------------------------------------------+
//| Draw or move a vertical line on the chart                        |
//+------------------------------------------------------------------+
void DrawVerticalLine(const datetime startOfDay)
{

   // Normalize to start of day (00:00)
   // MqlDateTime dt;
   // TimeToStruct(time, dt);
   // // dt.hour = 1;
   // // dt.min = 0;
   // // dt.sec = 0;
   // datetime startOfDay = StructToTime(dt);

   string name = line_prefix + "_DayStart_" + TimeToString(startOfDay, TIME_DATE) + " " + TimeToString(startOfDay, TIME_MINUTES);

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

//+------------------------------------------------------------------+
//| Function to remove all lines created by this EA                 |
//+------------------------------------------------------------------+
void RemoveAllLines()
{
   int total_objects = ObjectsTotal(0, -1, -1); 
   
   for (int i = total_objects - 1; i >= 0; i--)
   {
      string obj_name = ObjectName(0, i);
      
      // If the name is empty or we can't get it, skip
      if(obj_name == "" || obj_name == NULL) continue;

      // 1. PREFIX CHECK: Only touch our objects
      if (StringFind(obj_name, line_prefix) == 0)
      {
         ENUM_OBJECT type = (ENUM_OBJECT)ObjectGetInteger(0, obj_name, OBJPROP_TYPE);
         
         // 2. TYPE CHECK: Only delete standard UI objects we created
         // This avoids accidental interaction with Trade History arrows
         if(type == OBJ_VLINE || type == OBJ_HLINE || type == OBJ_LABEL || type == OBJ_RECTANGLE_LABEL)
         {
            ObjectDelete(0, obj_name);
         }
      }
   }
}

void RemoveAllLines2()
{
   DebugPrint("Starting optimized cleanup...");
   
   // This deletes ALL objects on the current chart (0) 
   // that start with your prefix (line_prefix)
   // and it is much faster/safer than a manual for-loop.
   ObjectsDeleteAll(0, line_prefix);
   
   // Also handle your specific Tooltip naming if it doesn't use the prefix
   ObjectsDeleteAll(0, "UI_"); 
   
   ChartRedraw(0);
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

void DrawMouseMarker(MqlRates &bar)
{
   string line_name = "UI_Mouse_Marker";
   string text_name = "UI_Mouse_Text";
   string rect_name = "UI_Mouse_Box"; // Name for the container

   // 1. Calculate Offsets
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   // Your current logic: 5.0 is a large price jump for FX, but works for Indices/Crypto
   double p_top = bar.high + 5.0;
   double p_bottom = bar.low - 5.0;

   // 2. --- DRAW THE LINE (OBJ_TREND) ---
   if (!ObjectCreate(0, line_name, OBJ_TREND, 0, bar.time, p_top, bar.time, p_bottom))
   {
      ObjectMove(0, line_name, 0, bar.time, p_top);
      ObjectMove(0, line_name, 1, bar.time, p_bottom);
   }
   ObjectSetInteger(0, line_name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, line_name, OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, line_name, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, line_name, OBJPROP_BACK, true);

   // // 3. --- PREPARE DATA ---
   // MqlDateTime dt;
   // TimeToStruct(bar.time, dt);
   // // string hourText = StringFormat("%02d:00", dt.hour);
   // string hourText = TimeToString(bar.time, TIME_MINUTES);

   // // We use the text position as our anchor for the box
   // datetime x_text = bar.time + 3600;
   // double y_text = p_top;
   
   // // Build detailed text based on timeframe
   // string details = hourText;
   // // switch (_Period)
   // // {
   // //    case PERIOD_M15:
   // //       details += StringFormat("\nO: %.5f | H: %.5f\nL: %.5f | C: %.5f", 
   // //                               bar.open, bar.high, bar.low, bar.close);
   // //       break;
   // //    case PERIOD_M30:
   // //       details += StringFormat("\nO: %.5f | H: %.5f\nL: %.5f | C: %.5f\nVol: %lld", 
   // //                               bar.open, bar.high, bar.low, bar.close, bar.tick_volume);
   // //       break;
   // //    case PERIOD_H1:
   // //       details += StringFormat("\nOpen: %.5f\nHigh: %.5f\nLow: %.5f\nClose: %.5f\nVolume: %lld", 
   // //                               bar.open, bar.high, bar.low, bar.close, bar.tick_volume);
   // //       break;
   // //    default:
   // //       details += StringFormat("\nH: %.5f | L: %.5f | C: %.5f", 
   // //                               bar.high, bar.low, bar.close);
   // //       break;
   // // }
   // hourText = details;

   // // 4. --- DRAW THE RECTANGLE (OBJ_RECTANGLE) ---
   // // We define the box boundaries relative to the text position
   // // Adjust these multipliers as you add more text
   // datetime x1 = x_text - 3600;       // Half bar left
   // datetime x2 = x_text + (3600 * 7); // Half bar right
   // double y1 = y_text + 2.0;          // Slightly above text
   // double y2 = y_text - 2.0;          // Slightly below text

   // // 5. --- DRAW THE TEXT (OBJ_TEXT) ---
   // if (!ObjectCreate(0, text_name, OBJ_TEXT, 0, x_text + 3600, y_text))
   // {
   //    ObjectMove(0, text_name, 0, x_text, y_text);
   // }

   // ObjectSetString(0, text_name, OBJPROP_TEXT, hourText);
   // ObjectSetString(0, text_name, OBJPROP_FONT, "Trebuchet MS");
   // ObjectSetInteger(0, text_name, OBJPROP_FONTSIZE, 8);
   // ObjectSetInteger(0, text_name, OBJPROP_COLOR, clrGreen);
   // ObjectSetInteger(0, text_name, OBJPROP_ANCHOR, ANCHOR_CENTER); // Changed to center for the box
   // ObjectSetInteger(0, text_name, OBJPROP_SELECTABLE, false);

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

      Print("Bar index under mouse: ", bar_index);
   // 3. Copy the bar data into the struct
   MqlRates rates[];
   if (CopyRates(_Symbol, _Period, bar_index, 1, rates) > 0)
   {
      bar_details = rates[0];
      return true;
   }

   return false;
}

bool GetNextRates(const MqlRates &current_rates, 
                  MqlRates &next_rates)
{
   // 1. Find the index of the bar that follows the current one
   // iBarShift finds the index of 'current_rates.time'
   int current_index = iBarShift(_Symbol, _Period, current_rates.time);
   
   // 2. The 'next' bar (closer to now) is index - 1
   int next_index = current_index - 1;

   // 3. Check if a next bar actually exists (current_index 0 is the latest)
   if(next_index < 0)
   {
      Print("Current bar is the latest bar. No 'next' bar exists yet.");
      return false;
   }

   // 4. Copy the data for that specific index
   MqlRates temp[1];
   if(CopyRates(_Symbol, _Period, next_index, 1, temp) > 0)
   {
      next_rates = temp[0];
      return true;
   }

   return false;
}

// Define names for each row

void DrawTooltipOnNextBar(const MqlRates &current_bar)
{
   MqlRates next_rates[];
   int next_index = iBarShift(_Symbol, _Period, current_bar.time) - 1;
   if(next_index < 0 || CopyRates(_Symbol, _Period, next_index, 1, next_rates) <= 0) return;
   
   color barColor = (current_bar.close >= current_bar.open) ? clrLimeGreen : clrRed;

   int x_pix, y_pix;
   if(!ChartTimePriceToXY(0, 0, next_rates[0].time, next_rates[0].high, x_pix, y_pix)) return;

   // 1. Manage the Background Rectangle
   if(ObjectFind(0, TOOLTIP_RECT_NAME) < 0) {
      ObjectCreate(0, TOOLTIP_RECT_NAME, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, TOOLTIP_RECT_NAME, OBJPROP_XSIZE, 300);
      ObjectSetInteger(0, TOOLTIP_RECT_NAME, OBJPROP_YSIZE, 95); // Slightly taller for rows
      ObjectSetInteger(0, TOOLTIP_RECT_NAME, OBJPROP_BGCOLOR, clrBlack);
   }
   ObjectSetInteger(0, TOOLTIP_RECT_NAME, OBJPROP_BORDER_COLOR, barColor);
   ObjectSetInteger(0, TOOLTIP_RECT_NAME, OBJPROP_XDISTANCE, x_pix + 10);
   ObjectSetInteger(0, TOOLTIP_RECT_NAME, OBJPROP_YDISTANCE, y_pix - 60);

// bar info 2
   int pips_oc = (int)MathAbs((current_bar.close - current_bar.open) / _Point);
   int pips_oh = (int)(MathAbs((current_bar.close < current_bar.open ? current_bar.open - current_bar.low : current_bar.high - current_bar.open)) / _Point);

   string bar_info2 = "";
   bool is_bullish = current_bar.close > current_bar.open;
   if (current_bar.close > current_bar.open)
   {
      int pips_r = (int)((current_bar.open - current_bar.low) / _Point);
      bar_info2 = StringFormat("↑:%d | ↑↑:%d | ↓R:%d [pips]",
                                 pips_oc, pips_oh, pips_r);
      // Print(current_bar.open, " ", current_bar.close, " ", current_bar.high, " ", current_bar.low , " ", (int)((current_bar.open - current_bar.low) * 100));
   }
   else
   {
      int pips_r = (int)((current_bar.high - current_bar.open) / _Point);
      bar_info2 = StringFormat("↓:%d | ↓↓:%d | ↑R:%d [pips]",
                                 pips_oc, pips_oh, pips_r);
   }

   // 2. Manage the Rows of Text
   string row_data[5];
   row_data[0] = StringFormat("%s", TimeToString(next_rates[0].time, TIME_DATE|TIME_MINUTES));
   row_data[1] = " ";
   row_data[2] = bar_info2;
   row_data[3] = StringFormat("High:  %.5f", next_rates[0].high);
   row_data[4] = StringFormat("Low:   %.5f", next_rates[0].low);

   for(int i = 0; i < 5; i++) {
      if(ObjectFind(0, TooltipRows[i]) < 0) {
         ObjectCreate(0, TooltipRows[i], OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, TooltipRows[i], OBJPROP_FONTSIZE, (i == 0) ? 10 : 8);
         ObjectSetString(0, TooltipRows[i], OBJPROP_FONT, "Consolas");
      }

      if(i == 0)
      {
         // ObjectSetInteger(0, TooltipRows[i], OBJPROP_COLOR, (is_bullish == true) ? clrGreen : clrRed);
         if(is_bullish)
            ObjectSetInteger(0, TooltipRows[i], OBJPROP_COLOR, clrGreen);
         else
            ObjectSetInteger(0, TooltipRows[i], OBJPROP_COLOR, clrRed);
      }
      else
      {
         ObjectSetInteger(0, TooltipRows[i], OBJPROP_COLOR, clrWhite);
      }
      ObjectSetString(0, TooltipRows[i], OBJPROP_TEXT, row_data[i]);
      ObjectSetInteger(0, TooltipRows[i], OBJPROP_XDISTANCE, x_pix + 15);
      // Increment Y position by 15 pixels for each row
      ObjectSetInteger(0, TooltipRows[i], OBJPROP_YDISTANCE, (y_pix - 55) + (i * 15));
   }
   
   ChartRedraw(0);
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

   string clockStr = StringFormat("Next Bar in: %02d:%02d:%02d", h, m, s);

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

   ChartRedraw(0);
}