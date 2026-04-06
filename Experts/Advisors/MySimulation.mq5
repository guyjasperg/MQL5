//+------------------------------------------------------------------+
//|                                       CandleReplaySimulator.mq5  |
//|                        Soft4FX-Style Candle Replay for MT5       |
//|                                          Complete Implementation |
//+------------------------------------------------------------------+
#property copyright "Your Name"
#property link      "your-email@example.com"
#property version   "1.00"
#property strict

// Input parameters
input group "=== Replay Settings ==="
input datetime InpStartDate = D'2026.03.10 00:00';    // Start Date
input datetime InpEndDate = D'2026.03.23 23:59';      // End Date
input int InpReplaySpeed = 500;                       // Speed (ms per candle)

input group "=== Visual Settings ==="
input color InpBullColor = clrLime;                   // Bullish Candle Color
input color InpBearColor = clrRed;                    // Bearish Candle Color
input color InpWickColor = clrBlack;                  // Wick Color
input int InpCandleWidth = 8;                        // Candle Body Width (%)

input group "=== Display Settings ==="
input bool InpShowGrid = false;                       // Show Grid
input bool InpShowVolume = true;                      // Show Volume

//+------------------------------------------------------------------+
//| Global Variables                                                   |
//+------------------------------------------------------------------+
enum ENUM_REPLAY_STATE
{
   REPLAY_STOPPED,
   REPLAY_PLAYING,
   REPLAY_PAUSED
};

// Replay control
ENUM_REPLAY_STATE g_replayState = REPLAY_STOPPED;
int g_currentIndex = 0;
MqlRates g_history[];
datetime g_historyTime[];
long g_historyVolume[];

// Chart objects
string g_objPrefix = "Replay_";
int g_maxVisibleCandles = 100;  // Number of candles to show on chart

// Control panel objects
string g_panelName = "ReplayPanel";
string g_btnPlay = "BtnPlay";
string g_btnPause = "BtnPause";
string g_btnStop = "BtnStop";
string g_btnFaster = "BtnFaster";
string g_btnSlower = "BtnSlower";
string g_lblStatus = "LblStatus";
string g_lblSpeed = "LblSpeed";
string g_lblInfo = "LblInfo";

// Current replay settings
int g_currentSpeed;
datetime g_currentTime = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   // Initialize speed
   g_currentSpeed = InpReplaySpeed;
   
   // Setup chart
   SetupChart();
   
   // Create control panel
   CreateControlPanel();
   
   // Load historical data
   if(!LoadHistory())
   {
      Print("Failed to load history data");
      return(INIT_FAILED);
   }
   
   // Setup timer for replay
   EventSetTimer(1);
   
   // Initial display
   UpdateStatusLabel("Ready - Press Play to Start");
   
   Print("Candle Replay Simulator initialized. Loaded ", ArraySize(g_history), " candles");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Stop timer
   EventKillTimer();
   
   // Cleanup all objects
   ObjectsDeleteAll(0, g_objPrefix);
   ObjectsDeleteAll(0, g_panelName);
   
   // Restore chart settings
   ChartSetInteger(0, CHART_SHOW_OHLC, true);
   ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS, true);
   ChartSetInteger(0, CHART_SHOW_GRID, true);
   
   ChartRedraw();
   
   Print("Candle Replay Simulator stopped");
}

//+------------------------------------------------------------------+
//| Expert tick function                                               |
//+------------------------------------------------------------------+
void OnTick()
{
   // Main logic is in OnTimer for controlled speed
   // OnTick used for button interactions
   CheckButtonClicks();
}

//+------------------------------------------------------------------+
//| Timer function                                                     |
//+------------------------------------------------------------------+
void OnTimer()
{
   if(g_replayState == REPLAY_PLAYING)
   {
      // Calculate timer interval based on speed
      static datetime lastUpdate = 0;
      datetime now = TimeLocal();
      
      if(now - lastUpdate >= g_currentSpeed / 1000)
      {
         ShowNextCandle();
         lastUpdate = now;
      }
   }
}

//+------------------------------------------------------------------+
//| ChartEvent function                                                |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      string objName = sparam;
      
      if(StringFind(objName, g_btnPlay) != -1)
      {
         StartReplay();
         ObjectSetInteger(0, objName, OBJPROP_STATE, false);
      }
      else if(StringFind(objName, g_btnPause) != -1)
      {
         PauseReplay();
         ObjectSetInteger(0, objName, OBJPROP_STATE, false);
      }
      else if(StringFind(objName, g_btnStop) != -1)
      {
         StopReplay();
         ObjectSetInteger(0, objName, OBJPROP_STATE, false);
      }
      else if(StringFind(objName, g_btnFaster) != -1)
      {
         SpeedUp();
         ObjectSetInteger(0, objName, OBJPROP_STATE, false);
      }
      else if(StringFind(objName, g_btnSlower) != -1)
      {
         SlowDown();
         ObjectSetInteger(0, objName, OBJPROP_STATE, false);
      }
   }
}

//+------------------------------------------------------------------+
//| Setup Chart Environment                                            |
//+------------------------------------------------------------------+
void SetupChart()
{
   // Hide default chart elements for clean replay view
   ChartSetInteger(0, CHART_SHOW_OHLC, false);
   ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS, false);
   ChartSetInteger(0, CHART_SHOW_GRID, InpShowGrid);
   ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrWhite);
   ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrBlack);
   ChartSetInteger(0, CHART_COLOR_GRID, clrLightGray);
   ChartSetInteger(0, CHART_COLOR_CHART_UP, InpBullColor);
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, InpBearColor);
   
   // Set to line chart mode to hide default candles (we draw our own)
   ChartSetInteger(0, CHART_MODE, CHART_LINE);
   
   // Adjust scale
   ChartSetDouble(0, CHART_FIXED_MAX, 0);
   ChartSetDouble(0, CHART_FIXED_MIN, 0);
   ChartSetInteger(0, CHART_SCALEFIX, false);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Load Historical Data                                               |
//+------------------------------------------------------------------+
bool LoadHistory()
{
   // Copy rates from history
   int copied = CopyRates(_Symbol, PERIOD_CURRENT, InpStartDate, InpEndDate, g_history);
   
   if(copied <= 0)
   {
      Print("Error copying history: ", GetLastError());
      return false;
   }
   
   // Resize arrays
   ArrayResize(g_historyTime, copied);
   ArrayResize(g_historyVolume, copied);
   
   // Store time and volume separately for easy access
   for(int i = 0; i < copied; i++)
   {
      g_historyTime[i] = g_history[i].time;
      g_historyVolume[i] = g_history[i].tick_volume;
   }
   
   Print("Loaded ", copied, " historical candles from ", TimeToString(InpStartDate), 
         " to ", TimeToString(InpEndDate));
   
   return true;
}

//+------------------------------------------------------------------+
//| Create Control Panel                                               |
//+------------------------------------------------------------------+
void CreateControlPanel()
{
   int panelX = 10;
   int panelY = 30;
   int panelWidth = 280;
   int panelHeight = 120;
   
   // Main panel background
   ObjectCreate(0, g_panelName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, g_panelName, OBJPROP_XDISTANCE, panelX);
   ObjectSetInteger(0, g_panelName, OBJPROP_YDISTANCE, panelY);
   ObjectSetInteger(0, g_panelName, OBJPROP_XSIZE, panelWidth);
   ObjectSetInteger(0, g_panelName, OBJPROP_YSIZE, panelHeight);
   ObjectSetInteger(0, g_panelName, OBJPROP_BGCOLOR, C'240,240,240');
   ObjectSetInteger(0, g_panelName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetString(0, g_panelName, OBJPROP_FONT, "Arial");
   
   // Title label
   string titleName = g_objPrefix + "Title";
   ObjectCreate(0, titleName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, titleName, OBJPROP_XDISTANCE, panelX + 10);
   ObjectSetInteger(0, titleName, OBJPROP_YDISTANCE, panelY + 10);
   ObjectSetString(0, titleName, OBJPROP_TEXT, "CANDLE REPLAY CONTROLLER");
   ObjectSetInteger(0, titleName, OBJPROP_COLOR, clrNavy);
   ObjectSetString(0, titleName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, titleName, OBJPROP_FONTSIZE, 10);
   
   // Play button
   CreateButton(g_btnPlay, "▶ PLAY", panelX + 10, panelY + 35, 60, 25, clrGreen);
   
   // Pause button
   CreateButton(g_btnPause, "⏸ PAUSE", panelX + 75, panelY + 35, 60, 25, clrOrange);
   
   // Stop button
   CreateButton(g_btnStop, "⏹ STOP", panelX + 140, panelY + 35, 60, 25, clrRed);
   
   // Speed controls
   CreateButton(g_btnSlower, "« Slow", panelX + 10, panelY + 65, 60, 22, clrBlue);
   CreateButton(g_btnFaster, "Fast »", panelX + 75, panelY + 65, 60, 22, clrBlue);
   
   // Speed label
   ObjectCreate(0, g_lblSpeed, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, g_lblSpeed, OBJPROP_XDISTANCE, panelX + 145);
   ObjectSetInteger(0, g_lblSpeed, OBJPROP_YDISTANCE, panelY + 70);
   UpdateSpeedLabel();
   
   // Status label
   ObjectCreate(0, g_lblStatus, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, g_lblStatus, OBJPROP_XDISTANCE, panelX + 10);
   ObjectSetInteger(0, g_lblStatus, OBJPROP_YDISTANCE, panelY + 95);
   ObjectSetInteger(0, g_lblStatus, OBJPROP_COLOR, clrBlack);
   ObjectSetString(0, g_lblStatus, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, g_lblStatus, OBJPROP_FONTSIZE, 9);
   
   // Info label (candle count)
   ObjectCreate(0, g_lblInfo, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, g_lblInfo, OBJPROP_XDISTANCE, panelX + 140);
   ObjectSetInteger(0, g_lblInfo, OBJPROP_YDISTANCE, panelY + 95);
   ObjectSetInteger(0, g_lblInfo, OBJPROP_COLOR, clrDarkGray);
   ObjectSetString(0, g_lblInfo, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, g_lblInfo, OBJPROP_FONTSIZE, 8);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Create Button Helper                                               |
//+------------------------------------------------------------------+
void CreateButton(string name, string text, int x, int y, int width, int height, color bgColor)
{
   string fullName = g_objPrefix + name;
   
   ObjectCreate(0, fullName, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, fullName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, fullName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, fullName, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, fullName, OBJPROP_YSIZE, height);
   ObjectSetString(0, fullName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, fullName, OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(0, fullName, OBJPROP_COLOR, clrWhite);
   ObjectSetString(0, fullName, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, fullName, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, fullName, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Check Button Clicks (Alternative to ChartEvent)                    |
//+------------------------------------------------------------------+
void CheckButtonClicks()
{
   // This is a backup method if ChartEvent doesn't trigger properly
   // Modern MT5 should use OnChartEvent primarily
}

//+------------------------------------------------------------------+
//| Replay Control Functions                                           |
//+------------------------------------------------------------------+
void StartReplay()
{
   if(g_replayState == REPLAY_STOPPED)
   {
      // Starting fresh
      g_currentIndex = 0;
      ClearAllCandles();
   }
   
   g_replayState = REPLAY_PLAYING;
   UpdateStatusLabel("Playing...");
   
   // Adjust timer for current speed
   EventKillTimer();
   int timerSeconds = MathMax(1, g_currentSpeed / 1000);
   EventSetTimer(timerSeconds);
   
   Print("Replay started at speed: ", g_currentSpeed, "ms");
}

void PauseReplay()
{
   g_replayState = REPLAY_PAUSED;
   UpdateStatusLabel("Paused");
   Print("Replay paused at candle ", g_currentIndex);
}

void StopReplay()
{
   g_replayState = REPLAY_STOPPED;
   g_currentIndex = 0;
   ClearAllCandles();
   UpdateStatusLabel("Stopped - Press Play to Start");
   Print("Replay stopped");
}

void SpeedUp()
{
   g_currentSpeed = MathMax(100, g_currentSpeed - 100);
   UpdateSpeedLabel();
   
   if(g_replayState == REPLAY_PLAYING)
   {
      EventKillTimer();
      int timerSeconds = MathMax(1, g_currentSpeed / 1000);
      EventSetTimer(timerSeconds);
   }
   
   Print("Speed increased to: ", g_currentSpeed, "ms");
}

void SlowDown()
{
   g_currentSpeed = MathMin(5000, g_currentSpeed + 100);
   UpdateSpeedLabel();
   
   if(g_replayState == REPLAY_PLAYING)
   {
      EventKillTimer();
      int timerSeconds = MathMax(1, g_currentSpeed / 1000);
      EventSetTimer(timerSeconds);
   }
   
   Print("Speed decreased to: ", g_currentSpeed, "ms");
}

//+------------------------------------------------------------------+
//| Update Label Functions                                             |
//+------------------------------------------------------------------+
void UpdateStatusLabel(string text)
{
   ObjectSetString(0, g_lblStatus, OBJPROP_TEXT, "Status: " + text);
   ChartRedraw();
}

void UpdateSpeedLabel()
{
   double seconds = g_currentSpeed / 1000.0;
   string speedText = StringFormat("Speed: %.1fs", seconds);
   ObjectSetString(0, g_lblSpeed, OBJPROP_TEXT, speedText);
   ChartRedraw();
}

void UpdateInfoLabel()
{
   int total = ArraySize(g_history);
   string info = StringFormat("Candle: %d/%d", g_currentIndex, total);
   ObjectSetString(0, g_lblInfo, OBJPROP_TEXT, info);
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Show Next Candle                                                   |
//+------------------------------------------------------------------+
void ShowNextCandle()
{
   int totalCandles = ArraySize(g_history);
   
   if(g_currentIndex >= totalCandles)
   {
      // End of replay
      g_replayState = REPLAY_STOPPED;
      UpdateStatusLabel("Finished - End of Data");
      Print("Replay finished - reached end of historical data");
      return;
   }
   
   // Get current candle data
   MqlRates currentCandle = g_history[g_currentIndex];
   
   // Calculate visible range (show last N candles)
   int startIdx = MathMax(0, g_currentIndex - g_maxVisibleCandles + 1);
   int visibleCount = g_currentIndex - startIdx + 1;
   
   // Clear old candles if we're moving window
   if(visibleCount >= g_maxVisibleCandles)
   {
      ClearOldCandles(startIdx - 1);
   }
   
   // Draw the new candle
   DrawCandle(g_currentIndex, currentCandle, visibleCount - 1);
   
   // Update chart scale to fit visible candles
   AdjustChartScale(startIdx, g_currentIndex);
   
   // Update info
   UpdateInfoLabel();
   
   // Increment index
   g_currentIndex++;
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Draw Single Candle                                                 |
//+------------------------------------------------------------------+
void DrawCandle(int index, const MqlRates &rate, int position)
{
   string bodyName = g_objPrefix + "Body_" + IntegerToString(index);
   string wickHighName = g_objPrefix + "WickHigh_" + IntegerToString(index);
   string wickLowName = g_objPrefix + "WickLow_" + IntegerToString(index);
   string volumeName = g_objPrefix + "Volume_" + IntegerToString(index);
   
   // Determine colors
   bool isBullish = rate.close >= rate.open;
   color bodyColor = isBullish ? InpBullColor : InpBearColor;
   
   // Calculate body coordinates
   double bodyTop = MathMax(rate.open, rate.close);
   double bodyBottom = MathMin(rate.open, rate.close);
   
   // Calculate time position (spread candles evenly)
   datetime timeStart = rate.time;
   datetime timeEnd = rate.time + PeriodSeconds();
   
   // Candle width adjustment
   int candleWidth = PeriodSeconds() * InpCandleWidth / 100;
   datetime bodyStart = timeStart + (PeriodSeconds() - candleWidth) / 2;
   datetime bodyEnd = bodyStart + candleWidth;
   
   // Draw body (rectangle)
   if(!ObjectCreate(0, bodyName, OBJ_RECTANGLE, 0, bodyStart, bodyTop, bodyEnd, bodyBottom))
   {
      // Object might exist, delete and recreate
      ObjectDelete(0, bodyName);
      ObjectCreate(0, bodyName, OBJ_RECTANGLE, 0, bodyStart, bodyTop, bodyEnd, bodyBottom);
   }
   
   ObjectSetInteger(0, bodyName, OBJPROP_COLOR, bodyColor);
   ObjectSetInteger(0, bodyName, OBJPROP_FILL, true);
   ObjectSetInteger(0, bodyName, OBJPROP_BACK, false);
   ObjectSetInteger(0, bodyName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, bodyName, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, bodyName, OBJPROP_ZORDER, 1);
   
   // Draw upper wick
   datetime centerTime = timeStart + PeriodSeconds() / 2;
   if(!ObjectCreate(0, wickHighName, OBJ_TREND, 0, centerTime, rate.high, centerTime, bodyTop))
   {
      ObjectDelete(0, wickHighName);
      ObjectCreate(0, wickHighName, OBJ_TREND, 0, centerTime, rate.high, centerTime, bodyTop);
   }
   
   ObjectSetInteger(0, wickHighName, OBJPROP_COLOR, InpWickColor);
   ObjectSetInteger(0, wickHighName, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, wickHighName, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, wickHighName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, wickHighName, OBJPROP_HIDDEN, true);
   
   // Draw lower wick
   if(!ObjectCreate(0, wickLowName, OBJ_TREND, 0, centerTime, bodyBottom, centerTime, rate.low))
   {
      ObjectDelete(0, wickLowName);
      ObjectCreate(0, wickLowName, OBJ_TREND, 0, centerTime, bodyBottom, centerTime, rate.low);
   }
   
   ObjectSetInteger(0, wickLowName, OBJPROP_COLOR, InpWickColor);
   ObjectSetInteger(0, wickLowName, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, wickLowName, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, wickLowName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, wickLowName, OBJPROP_HIDDEN, true);
   
   // Draw volume (optional)
   if(InpShowVolume && rate.tick_volume > 0)
   {
      double volScale = 0.1;  // Scale factor for volume bars
      double volHigh = rate.low - (_Point * 50);  // Position below candle
      double volLow = volHigh - (rate.tick_volume * volScale * _Point);
      
      if(!ObjectCreate(0, volumeName, OBJ_RECTANGLE, 0, bodyStart, volHigh, bodyEnd, volLow))
      {
         ObjectDelete(0, volumeName);
         ObjectCreate(0, volumeName, OBJ_RECTANGLE, 0, bodyStart, volHigh, bodyEnd, volLow);
      }
      
      ObjectSetInteger(0, volumeName, OBJPROP_COLOR, clrLightBlue);
      ObjectSetInteger(0, volumeName, OBJPROP_FILL, true);
      ObjectSetInteger(0, volumeName, OBJPROP_BACK, true);
      ObjectSetInteger(0, volumeName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, volumeName, OBJPROP_HIDDEN, true);
   }
}

//+------------------------------------------------------------------+
//| Clear All Candles                                                  |
//+------------------------------------------------------------------+
void ClearAllCandles()
{
   ObjectsDeleteAll(0, g_objPrefix + "Body_");
   ObjectsDeleteAll(0, g_objPrefix + "WickHigh_");
   ObjectsDeleteAll(0, g_objPrefix + "WickLow_");
   ObjectsDeleteAll(0, g_objPrefix + "Volume_");
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Clear Old Candles (for sliding window)                               |
//+------------------------------------------------------------------+
void ClearOldCandles(int index)
{
   string bodyName = g_objPrefix + "Body_" + IntegerToString(index);
   string wickHighName = g_objPrefix + "WickHigh_" + IntegerToString(index);
   string wickLowName = g_objPrefix + "WickLow_" + IntegerToString(index);
   string volumeName = g_objPrefix + "Volume_" + IntegerToString(index);
   
   ObjectDelete(0, bodyName);
   ObjectDelete(0, wickHighName);
   ObjectDelete(0, wickLowName);
   ObjectDelete(0, volumeName);
}

//+------------------------------------------------------------------+
//| Adjust Chart Scale - Smart Version                                 |
//+------------------------------------------------------------------+
void AdjustChartScale(int startIdx, int endIdx)
{
   if(startIdx < 0 || endIdx >= ArraySize(g_history)) return;
   
   // Get current visible price range to check if user manually scaled
   static double lastFixedMax = 0;
   static double lastFixedMin = 0;
   static bool firstRun = true;
   
   double currentMax, currentMin;
   ChartGetDouble(0, CHART_FIXED_MAX, 0, currentMax);
   ChartGetDouble(0, CHART_FIXED_MIN, 0, currentMin);
   
   // Calculate required range for visible candles
   double highestHigh = g_history[startIdx].high;
   double lowestLow = g_history[startIdx].low;
   
   for(int i = startIdx; i <= endIdx && i < ArraySize(g_history); i++)
   {
      if(g_history[i].high > highestHigh) highestHigh = g_history[i].high;
      if(g_history[i].low < lowestLow) lowestLow = g_history[i].low;
   }
   
   // Add padding (5% margin)
   double range = highestHigh - lowestLow;
   double padding = range * 0.05;
   highestHigh += padding;
   lowestLow -= padding;
   
   // Check if current candle is visible in current scale
   bool candleVisible = (highestHigh <= currentMax && lowestLow >= currentMin) ||
                        (currentMax == 0 && currentMin == 0);  // Auto-scale mode
   
   // Only auto-scale if:
   // 1. First run
   // 2. Candle is not visible in current view
   // 3. Scale hasn't been manually changed by user (detected by comparing with last values)
   bool userChangedScale = (lastFixedMax != 0 && lastFixedMin != 0) && 
                         (MathAbs(currentMax - lastFixedMax) > 0.0001 || 
                          MathAbs(currentMin - lastFixedMin) > 0.0001);
   
   if(firstRun || !candleVisible)
   {
      // Apply new scale
      ChartSetDouble(0, CHART_FIXED_MAX, highestHigh);
      ChartSetDouble(0, CHART_FIXED_MIN, lowestLow);
      ChartSetInteger(0, CHART_SCALEFIX, true);
      
      lastFixedMax = highestHigh;
      lastFixedMin = lowestLow;
      firstRun = false;
   }
   else if(!userChangedScale)
   {
      // Update our tracking of current scale (normal progression)
      lastFixedMax = currentMax;
      lastFixedMin = currentMin;
   }
   else
   {
      // User manually changed scale - respect it and update tracking
      lastFixedMax = currentMax;
      lastFixedMin = currentMin;
      
      // Optional: Check if we need to pan to keep candle visible even if scale is manual
      // This allows user to zoom but still follow the price action
      if(highestHigh > currentMax || lowestLow < currentMin)
      {
         // Candle is going out of view - adjust just the position, not scale
         // Actually, better to let user control fully when they manually scale
         // So we do nothing here - user controls the view
      }
   }
   
   // Navigate to show latest candles
   ChartNavigate(0, CHART_END, 0);
}

//+------------------------------------------------------------------+
//| Jump to Specific Candle (for future enhancement)                   |
//+------------------------------------------------------------------+
bool JumpToCandle(int index)
{
   if(index < 0 || index >= ArraySize(g_history)) return false;
   
   // Clear current display
   ClearAllCandles();
   
   // Set new position
   g_currentIndex = index;
   
   // Redraw all visible candles up to this point
   int startIdx = MathMax(0, index - g_maxVisibleCandles + 1);
   
   for(int i = startIdx; i <= index; i++)
   {
      DrawCandle(i, g_history[i], i - startIdx);
   }
   
   AdjustChartScale(startIdx, index);
   UpdateInfoLabel();
   ChartRedraw();
   
   return true;
}

//+------------------------------------------------------------------+
//| Get Current Replay Information                                     |
//+------------------------------------------------------------------+
string GetReplayInfo()
{
   string info = "Replay Info:\n";
   info += "State: " + EnumToString(g_replayState) + "\n";
   info += "Current Index: " + IntegerToString(g_currentIndex) + "\n";
   info += "Total Candles: " + IntegerToString(ArraySize(g_history)) + "\n";
   info += "Speed: " + IntegerToString(g_currentSpeed) + "ms\n";
   
   if(g_currentIndex > 0 && g_currentIndex <= ArraySize(g_history))
   {
      info += "Current Time: " + TimeToString(g_history[g_currentIndex-1].time) + "\n";
      info += "Current Price: " + DoubleToString(g_history[g_currentIndex-1].close, _Digits);
   }
   
   return info;
}
//+------------------------------------------------------------------+