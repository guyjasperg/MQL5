using System;
using System.Collections.Concurrent;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;
using System.Text.RegularExpressions;

namespace MQLBridge
{
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public unsafe struct GenericEvent
    {
        public int CommandID;
        public long LongValue;
        public double DoubleValue;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 64)]
        public string StringValue;
    }

    public static class MQLBridge
    {
        private static volatile bool _uiReady = false;
        private static frmUI _form;
        private static Thread _uiThread;
        private static DateTime _lastHeartbeat = DateTime.Now;
        private static bool _formClosed = false;
        private static string _lastMessage = "";
        private static System.Windows.Forms.Timer _connectionTimer;

        private static ConcurrentQueue<GenericEvent> _commandQueue = new ConcurrentQueue<GenericEvent>();

        // Windows API declarations
        [DllImport("user32.dll", SetLastError = true)]
        private static extern IntPtr SetParent(IntPtr hWndChild, IntPtr hWndNewParent);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

        [DllImport("user32.dll")]
        private static extern IntPtr GetForegroundWindow();

        [DllImport("user32.dll")]
        private static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder text, int count);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern int GetWindowLong(IntPtr hWnd, int nIndex);

        [DllImport("user32.dll")]
        private static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

        private const int GWL_STYLE = -16;
        private const int WS_CHILD = 0x40000000;
        private const int WS_POPUP = unchecked((int)0x80000000);

        public static void StartUI(long chartHandle)
        {
            Logger.Initialize(LogLevel.Debug, 1024 * 1024 * 10);
            Logger.Info("Starting UI...");

            if (_uiThread != null && _uiThread.IsAlive)
            {
                //form is already running, just bring it to front
                _form.BeginInvoke(new Action(() => {
                    _form.GetSettings();
                }));
                return;
            }

            IntPtr parentHandle = new IntPtr(chartHandle);
            _formClosed = false; // Reset flag

            _uiThread = new Thread(() =>
            {
                Application.EnableVisualStyles();
                _form = new frmUI();
                _uiReady = true;

                // Initialize the Heartbeat Watchdog
                _connectionTimer = new System.Windows.Forms.Timer();
                _connectionTimer.Interval = 5000; // Check every 5 seconds
                _connectionTimer.Tick += (s, e) => {
                    if ((DateTime.Now - _lastHeartbeat).TotalSeconds > 10)
                    {
                        // MT5 hasn't polled us in 10 seconds - it's likely closed
                        Application.Exit();
                    }
                };
                //_connectionTimer.Start();
                
                //subscribe to event
                _form.OnUICommand += _form_OnUICommand ;
                _form.FormClosing += OnFormClosing;
                _form.FormClosed += OnFormClosed;

                // CRITICAL: Set form properties BEFORE showing
                _form.FormBorderStyle = FormBorderStyle.FixedToolWindow; // Or SizableToolWindow
                _form.StartPosition = FormStartPosition.Manual;
                _form.TopMost = false; // Important: Don't use TopMost with child windows
                _form.ShowInTaskbar = false; // Hide from taskbar

                // Show the form first (but not as a dialog)
                _form.Show();

                // THEN set the parent relationship
                if (parentHandle != IntPtr.Zero)
                {
                    // Make it a child window of MT5
                    IntPtr formHandle = _form.Handle;
                    SetParent(formHandle, parentHandle);

                    // Optional: Modify window style to be a true child window
                    //int style = GetWindowLong(formHandle, GWL_STYLE);
                    //style = (style & ~WS_POPUP) | WS_CHILD;
                    //SetWindowLong(formHandle, GWL_STYLE, style);

                    // *** NEW: Pass parent handle to form for constraint checking ***
                    _form.SetParentHandle(parentHandle);

                    // Position the form
                    _form.Left = 20;
                    _form.Top = 20;
                }

                Application.Run(_form);
            });

            _uiThread.SetApartmentState(ApartmentState.STA);
            _uiThread.Start();
        }

        private static void OnFormClosed(object sender, FormClosedEventArgs e)
        {
            // Set flag and send close command to MQL5
            _formClosed = true;

            // Queue a special event to signal EA removal
            var closeEvent = new GenericEvent
            {
                CommandID = 9999,  // Special command ID for form close
                StringValue = "FORM_CLOSED"
            };
            _commandQueue.Enqueue(closeEvent);
        }

        public static bool IsFormClosed()
        {
            return _formClosed;
        }
        private static void OnFormClosing(object sender, FormClosingEventArgs e)
        {
            // Optional: Add confirmation dialog
            // var result = MessageBox.Show("Close the form? This will remove the EA.", 
            //     "Confirm", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
            // if (result == DialogResult.No)
            // {
            //     e.Cancel = true;
            //     return;
            // }
        }

        private static void _form_OnUICommand(int id, object data)
        {
            var evt = new GenericEvent { CommandID = id, StringValue = "" };

            // Type switch to fill the relevant field
            switch (data)
            {
                case double d: evt.DoubleValue = d; break;
                case long l: evt.LongValue = l; break;
                case int i: evt.LongValue = i; break;
                case string s: evt.StringValue = s; break;
            }
            _commandQueue.Enqueue(evt);
            _lastHeartbeat = DateTime.Now;

            Logger.Info($"Enqueued event: ID={evt.CommandID}, Long={evt.LongValue}, Double={evt.DoubleValue}, String='{evt.StringValue}'");
        }

         //[DllExport(CallingConvention = CallingConvention.StdCall)]
        public static unsafe void GetNextEvent([MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 1)] ushort[] buffer, int maxLength)
        {
            _lastHeartbeat = DateTime.Now;
            GenericEvent evt;
            string result = "";

            if (_commandQueue.TryDequeue(out evt))
            {
                result = $"{evt.CommandID},";
                //Logger.Info($"Dequeued event: ID={evt.CommandID}, Long={evt.LongValue}, Double={evt.DoubleValue}, String='{evt.StringValue}'");
                if (evt.DoubleValue != 0)
                {
                    result += $"{evt.DoubleValue}";
                }
                else if (evt.LongValue != 0)
                {
                    result += $"{evt.LongValue}";
                }
                else if (!string.IsNullOrEmpty(evt.StringValue))
                {
                    result += $"{evt.StringValue}";
                }
            }
            // If queue is empty, result remains ""

            // Copy result to buffer
            int length = Math.Min(result.Length, maxLength - 1);
            for (int i = 0; i < length; i++)
            {
                buffer[i] = result[i];
            }
            buffer[length] = 0; // null terminator
        }

        public static int PeekNextEvent()
        {
            // TryPeek lets us look at the struct without removing it
            if (_commandQueue.TryPeek(out GenericEvent evt))
            {
                return evt.CommandID;
            }

            // Return -1 (or 0) if the queue is empty
            return 0;
        }

        // Use IntPtr for the signature to make it "MQL5-friendly"
        // Make sure your DLL is compiled with "Allow unsafe code" enabled
        public static unsafe void GetLastMessage([MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 1)] ushort[] buffer, int maxLength)
        {
            string msg = "Hello from WinForms!";
            int length = Math.Min(msg.Length, maxLength - 1);

            for (int i = 0; i < length; i++)
            {
                buffer[i] = msg[i];
            }
            buffer[length] = 0; // null terminator
            _lastHeartbeat = DateTime.Now;
        }

        public static unsafe void SendMessage(
        [MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 1)] ushort[] buffer,
        int length, int msgID)
        {
            if (_uiReady && _form != null && !_form.IsDisposed)
            {
                try
                {
                    if (buffer == null || length <= 0)
                        return;

                    char[] chars = new char[length];
                    for (int i = 0; i < length && buffer[i] != 0; i++)
                    {
                        chars[i] = (char)buffer[i];
                    }

                    string msg = new string(chars).TrimEnd('\0');

                    //Console.WriteLine("Message from MQL5: " + _lastMessage);
                    _lastHeartbeat = DateTime.Now;

                    if (msgID == (int)UIMessageIDs.BarData)
                    {
                        // Process BarData message if needed
                        _form.BeginInvoke(new Action(() => {
                            //_form.lblCurrentBar.Text = msg;

                            // The pattern for YYYY.MM.DD
                            string pattern = @"\d{4}\.\d{2}\.\d{2}";

                            Match match = Regex.Match(msg, pattern);
                            if (match.Success)
                            {
                                _form.lblCurrentBar.Text = match.Groups[0].Value;
                            }

                            //get time part of msg
                            // Pattern: looks for 2 digits, a colon, and 2 digits followed by a closing bracket
                            match = Regex.Match(msg, @"(\d{2}:\d{2})(?=\])");
                            if (match.Success)
                            {
                                _form.lblBarTime.Text = match.Groups[1].Value;
                            }

                            //BO part
                            pattern = @"BO\s\d+%";
                            match = Regex.Match(msg, pattern);
                            _form.lblBO.Visible = match.Success;
                            _form.lblBO.Text = match.Success ? match.Value : "";
                        }));
                    }
                    else if (msgID == (int)UIMessageIDs.BarData2)
                    {
                        // Process BarData message if needed
                        _form.BeginInvoke(new Action(() => {
                            
                            _form.lblData2.Text = msg.Remove(0,7);
                        }));
                    }
                    else if (msgID == (int)UIMessageIDs.BarOHCL)
                    {
                        string []tokens = msg.Split(',');
                        if (tokens != null && tokens.Length == 4)
                        {
                            _form.BeginInvoke(new Action(() => {
                                _form.UpdateCandleInfo(double.Parse(tokens[0]), double.Parse(tokens[1]), double.Parse(tokens[2]), double.Parse(tokens[3]));
                            }));
                        }
                    }
                    else if (msgID == (int)UIMessageIDs.CountdownUpdate)
                    {
                        //show countdown
                        _form.BeginInvoke(new Action(() => {
                            _form.lblTimeLeft.Text = msg;
                        }));
                    }
                    else if (msgID == (int)UIMessageIDs.AccountBalance)
                    {
                        //show countdown
                        _form.BeginInvoke(new Action(() => {
                            _form.lblAccountBalance.Text = msg;
                        }));
                    }
                    else if (msgID == (int)UIMessageIDs.TradeExecuted)
                    {
                        Logger.Info("Trade executed...");
                        _form.BeginInvoke(new Action(() => {
                            _form.pnlBuySell.Enabled = true;
                        }));
                    }
                    else if (msgID == (int)UIMessageIDs.TradeHistory)
                    {
                        Logger.Info("TradeHistory received...");
                        _form.BeginInvoke(new Action(() => {
                            _form.ShowTradeHistory(msg);
                        }));
                    }
                        _lastMessage = msg;
                    _lastHeartbeat = DateTime.Now;
                }
                catch (Exception ex)
                {
                    Logger.Error("Error in SendMessage: " + ex.Message, ex);
                    MessageBox.Show("Error in SendMessage: " + ex.Message);
                    //DO nothing
                    //throw;
                }
            }
        }

        // This method will be called directly from MQL5
        public static unsafe void UpdateBarDetails(int barIndex, double open, double close, double high, double low, long time)
        {
            if (!_uiReady || _form == null || _form.IsDisposed) return;

            // Convert MQL time (seconds since 1970) to C# DateTime
            DateTime dt = DateTimeOffset.FromUnixTimeSeconds(time).DateTime;

            // Use Invoke to update UI from the MQL thread safely
            _form.BeginInvoke(new Action(() => {
                _form.lblCurrentBar.Text = barIndex.ToString();
                //_form.lblBarIndex.Text = $"Index: {barIndex}";
                //_form.lblPrice.Text = $"O: {open} | C: {close}";
                //_form.lblTime.Text = dt.ToString("yyyy.MM.dd HH:mm");
            }));
            _lastHeartbeat = DateTime.Now;
        }
    }

    // Helper class to wrap window handle
    public class Win32Window : IWin32Window
    {
        private readonly IntPtr _handle;

        public Win32Window(IntPtr handle)
        {
            _handle = handle;
        }

        public IntPtr Handle
        {
            get { return _handle; }
        }
    }
}
;