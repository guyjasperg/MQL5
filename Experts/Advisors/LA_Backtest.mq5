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
  if(!MyUI.Create(0, "ControlPanel", 0, 50, 50, 300, 250))
    return INIT_FAILED;
    
  MyUI.Run();
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
   //MyUI.On(id, lparam, dparam, sparam);
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