using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Drawing.Text;
using System.Runtime.InteropServices;
using System.Security.AccessControl;
using System.Windows.Forms;

namespace MQLBridge
{
    public struct CandleInfo
    {
        public double Open;
        public double High;
        public double Low;
        public double Close;
        public string TimeLabel; // The "08:00" string from your parser
    }
    public partial class frmUI : Form
    {
        // The second parameter is now a generic object
        public event Action<int, object> OnUICommand;
        private IntPtr _parentHandle = IntPtr.Zero;
        private const int WM_EXITSIZEMOVE = 0x0232;
        private frmTradeHistory _frmTradeHistory;
        private CandleInfo _candleInfo;

        [DllImport("user32.dll", SetLastError = true)]
        private static extern IntPtr SetParent(IntPtr hWndChild, IntPtr hWndNewParent);

        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool SetForegroundWindow(IntPtr hWnd);
        public frmUI()
        {
            InitializeComponent();
            Logger.Info("frmUI initialized");
        }

        // Call this method to set the parent handle after form creation
        public void SetParentHandle(IntPtr parentHandle)
        {
            _parentHandle = parentHandle;
        }

        protected override void WndProc(ref Message m)
        {
            base.WndProc(ref m);

            // This message is sent when user RELEASES the mouse after dragging
            if (m.Msg == WM_EXITSIZEMOVE && _parentHandle != IntPtr.Zero)
            {
                ConstrainToParent();
            }
        }

        public void UpdateCandleInfo(double open, double high, double close, double low,  string timeLabel="")
        {
            _candleInfo.Open = open;
            _candleInfo.High = high;
            _candleInfo.Low = low;
            _candleInfo.Close = close;
            _candleInfo.TimeLabel = timeLabel;

            //repaint the candle info on the UI
            picBar.Invalidate();
        }

        public void SendUICOmmand(int commandID, object payload)
        {
            OnUICommand?.Invoke(commandID, payload);
        }

        private void ConstrainToParent()
        {
            return;

            RECT parentRect;
            if (!GetWindowRect(_parentHandle, out parentRect))
                return;

            int parentWidth = parentRect.Right - parentRect.Left;
            int parentHeight = parentRect.Bottom - parentRect.Top;

            int newLeft = this.Left;
            int newTop = this.Top;
            bool needsAdjustment = false;

            // Constrain LEFT
            if (this.Left < 0)
            {
                newLeft = 0;
                needsAdjustment = true;
            }

            // Constrain RIGHT
            if (this.Left + this.Width > parentWidth)
            {
                newLeft = Math.Max(0, parentWidth - this.Width);
                needsAdjustment = true;
            }

            // Constrain TOP
            if (this.Top < 0)
            {
                newTop = 0;
                needsAdjustment = true;
            }

            // Constrain BOTTOM
            if (this.Top + this.Height > parentHeight)
            {
                newTop = Math.Max(0, parentHeight - this.Height);
                needsAdjustment = true;
            }

            if (needsAdjustment)
            {
                this.Location = new Point(newLeft, newTop);
            }
        }

        // PSEUDOCODE / PLAN:
        // - Start from the current date shown in dtDate (use the Date property to ignore time).
        // - If the current date is already DateTime.MinValue, do nothing (can't go earlier).
        // - Move back one day at a time.
        // - After each decrement, check DayOfWeek. If it's Saturday or Sunday, continue looping.
        // - Stop when a non-weekend day is found or DateTime.MinValue is reached.
        // - Assign the found date back to dtDate.Value.
        private void btnDayPrevious_Click(object sender, EventArgs e)
        {
            // If we're already at MinValue, do nothing.
            if (dtDate.Value.Date <= DateTime.MinValue.Date)
            {
                return;
            }

            DateTime candidate = dtDate.Value.Date;

            // Move backwards until we find a non-weekend day or hit MinValue.
            while (true)
            {
                // Prevent underflow: if candidate is already MinValue, stop.
                if (candidate == DateTime.MinValue)
                    break;

                candidate = candidate.AddDays(-1);

                // If candidate is not Saturday or Sunday, we found a valid day.
                if (candidate.DayOfWeek != DayOfWeek.Saturday && candidate.DayOfWeek != DayOfWeek.Sunday)
                    break;
            }

            // Update the control with the found weekday.
            dtDate.Value = candidate;
        }

        private void btnDayNext_Click(object sender, EventArgs e)
        {
            // If we're already at or past today, do nothing.
            if (dtDate.Value.Date >= DateTime.Now.Date)
            {
                return;
            }

            DateTime candidate = dtDate.Value.Date;

            while (true)
            {
                // Move to the next day
                candidate = candidate.AddDays(1);

                // If we've gone past today, we must not set a future date -> abort without changing.
                if (candidate > DateTime.Now.Date)
                    break;

                // If candidate is Saturday or Sunday, skip it and continue searching.
                if (candidate.DayOfWeek == DayOfWeek.Saturday || candidate.DayOfWeek == DayOfWeek.Sunday)
                    continue;

                // Found a valid non-weekend day within allowed range -> apply and exit.
                dtDate.Value = candidate;
                break;
            }
        }

        private void btnDayCurrent_Click(object sender, EventArgs e)
        {
            dtDate.Value = DateTime.Now;
        }

        public void frmReloaded()
        {
            Logger.Info("frmUI reloaded");
            btnDayCurrent.PerformClick();
        }
        private void frmUI_Load(object sender, EventArgs e)
        {
            // Enable form to receive key events before child controls
            this.KeyPreview = true;
            this.KeyDown += frmUI_KeyDown;

            //populate cboDays
            for (int i = 1; i <= 60; i++)
            {
                cboDays.Items.Add(i.ToString());
            }
            //default value
            lblBO.Text = "";
            cboDays.SelectedIndex = 6;
            dtDate.Value = DateTime.Now;
            pnlBuySell.Visible = false;
            btnShowBuySell.PerformClick();
            Init_LotSize();
            cboTP.SelectedIndex = 0;
            cboSL.SelectedIndex = 0;
            _candleInfo = new CandleInfo();

            _frmTradeHistory = new frmTradeHistory();
            Logger.Info("frmUI loaded");
        }

        private void Init_LotSize()
        {
            double lotSize = 0.00; // default value

            while(lotSize<=1)
            {
                lotSize += 0.01;
                cboLotSize.Items.Add(lotSize.ToString("0.00"));
            }
            cboLotSize.SelectedIndex = 0;

            cboTP.Items.Add("400");
            cboTP.Items.Add("500");
            cboTP.Items.Add("800");
            cboTP.Items.Add("900");
            cboTP.Items.Add("1000");
            cboTP.Items.Add("1500");
            cboTP.Items.Add("2000");
            cboTP.SelectedIndex = 0;

            cboSL.Items.Add("2000");
            cboSL.Items.Add("2500");
            cboSL.Items.Add("3000");
            cboSL.Items.Add("3250");
            cboSL.Items.Add("3500");
            cboSL.Items.Add("4000");
            cboSL.SelectedIndex = 0;
        }

        public void GetSettings()
        {
            string _currentSettings = "";

            //S1 Days
            _currentSettings += string.Format("{0},", cboDays.SelectedIndex + 1);

            //Send Notification
            _currentSettings += string.Format("{0},", chkNotification.Checked ? "1":"0");

            OnUICommand?.Invoke((int)UIMessageIDs.Config, _currentSettings);

            string sDate = dtDate.Value.ToString("yyyy.MM.dd");
            OnUICommand?.Invoke((int)UIMessageIDs.SetS1Days, sDate);
        }

        public void Set_S1Days(int days)
        {
            cboDays.SelectedIndex = days - 1;
        }

        private void cboDays_SelectedIndexChanged(object sender, EventArgs e)
        {
            GetSettings();
        }

        private void dtDate_ValueChanged(object sender, EventArgs e)
        {
            string sDate = dtDate.Value.ToString("yyyy.MM.dd");
            OnUICommand?.Invoke(3, sDate);
        }

        private void checkBox1_CheckedChanged(object sender, EventArgs e)
        {

        }

        // Windows API to get window rectangle
        [DllImport("user32.dll")]
        private static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

        [StructLayout(LayoutKind.Sequential)]
        private struct RECT
        {
            public int Left;
            public int Top;
            public int Right;
            public int Bottom;
        }

        private void chkNotification_CheckedChanged(object sender, EventArgs e)
        {
            GetSettings();
        }

        private void btnChartMoveLeft_Click(object sender, EventArgs e)
        {
            //Move backward
            OnUICommand?.Invoke((int)UIMessageIDs.ChartNavigate, "Right");
        }

        private void btnChartMoveRight_Click(object sender, EventArgs e)
        {
            //Move forward
            OnUICommand?.Invoke((int)UIMessageIDs.ChartNavigate, "Left");
        }

        // New: handle left/right arrow keys and trigger corresponding chart move buttons
        private void frmUI_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Left)
            {
                // simulate left button click
                if (btnChartMoveLeft != null)
                    btnChartMoveLeft.PerformClick();

                e.Handled = true;
            }
            else if (e.KeyCode == Keys.Right)
            {
                // simulate right button click
                if (btnChartMoveRight != null)
                    btnChartMoveRight.PerformClick();

                e.Handled = true;
            }
        }

        private void btnTradeHistory_Click(object sender, EventArgs e)
        {
            //Notify MQL we need to load trade history for the current date
            //OnUICommand?.Invoke((int)UIMessageIDs.TradeHistory, dtDate.Value.ToString("yyyy.MM.dd"));

            if(_frmTradeHistory == null || _frmTradeHistory.IsDisposed)
            {
                _frmTradeHistory = new frmTradeHistory();                
            }   
            _frmTradeHistory.parentForm = this;
            _frmTradeHistory.Show();
            SetParent(_frmTradeHistory.Handle, this._parentHandle);
        }

        public void Send_OnUICommand(int commandID, string payload)
        {
            OnUICommand?.Invoke(commandID, payload);
        }

        public void ShowTradeHistory(string tradeData)
        {
            Logger.Info("frmUI.ShowTradeHistory()");
            if (_frmTradeHistory != null && !_frmTradeHistory.IsDisposed)
            {
                _frmTradeHistory.ShowTradeHistory(tradeData);
            }
        }

        private void btnShowBuySell_Click(object sender, EventArgs e)
        {
            if((string)btnShowBuySell.Tag == "Right")
            {
                //show Buy / Sell 
                this.Width = 780;
                pnlBuySell.Visible = true;
                btnShowBuySell.Tag = "Left";
                btnShowBuySell.BackgroundImage = Properties.Resources.left;
            }
            else
            {
                //show Buy / Sell 
                this.Width = 490;
                pnlBuySell.Visible = false;
                btnShowBuySell.Tag = "Right";
                btnShowBuySell.BackgroundImage = Properties.Resources.right;
            }
        }

        private void SendBuySellCommand(string command)
        {
            string lotSize = cboLotSize.SelectedItem.ToString();
            string tp = cboTP.Text;
            string sl = cboSL.Text;

            // ensure numeric values
            if (!int.TryParse(tp, out _) || !int.TryParse(sl, out _))
            {
                MessageBox.Show("TP and SL must be numeric.", "Validation", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            string payload = $"{command}|{lotSize}|{tp}|{sl}";
            OnUICommand?.Invoke((int)UIMessageIDs.BuySell, payload);

            //disable UI to avoid multiple clicks until we get a response from MQL
            pnlBuySell.Enabled = false;
        }

        private void btnSell_Click(object sender, EventArgs e)
        {
            SendBuySellCommand("SELL");
        }

        private void button1_Click(object sender, EventArgs e)
        {
            SendBuySellCommand("BUY");
        }

        private void btnSetDate_Click(object sender, EventArgs e)
        {
            string sDate = dtDate.Value.ToString("yyyy.MM.dd");
            OnUICommand?.Invoke((int)UIMessageIDs.SetS1Days, sDate);
        }

        private void btnBuy_Click(object sender, EventArgs e)
        {
            SendBuySellCommand("BUY");
        }

        private void btnMarketHours_Click(object sender, EventArgs e)
        {
            frmTradingHours frm = new frmTradingHours();
            frm.Show();
        }

        private void frmUI_FormClosed(object sender, FormClosedEventArgs e)
        {

        }

        private void frmUI_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (this._parentHandle != IntPtr.Zero)
            {
                // Force Windows to bring the MT5 Chart back to the front
                SetForegroundWindow(this._parentHandle);
            }
        }

        private void picBar_Paint(object sender, PaintEventArgs e)
        {
            if (_candleInfo.High == 0) return; // Don't draw if no data

            Graphics g = e.Graphics;
            g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
            g.TextRenderingHint = TextRenderingHint.ClearTypeGridFit;

            // 1. Setup Dimensions
            float h = picBar.Height;
            float w = picBar.Width;
            float centerX = w / 2;
            float bodyWidth = w * 0.4f;

            // 2. Scaling Math (Map Price to Pixels)
            double range = _candleInfo.High - _candleInfo.Low;
            if (range <= 0) range = 0.00001; // Avoid division by zero

            // Convert price to Y-coordinate: (High - Price) / Range * Height
            float yHigh = 0;
            float yLow = h;
            float yOpen = (float)((_candleInfo.High - _candleInfo.Open) / range * h);
            float yClose = (float)((_candleInfo.High - _candleInfo.Close) / range * h);

            // 3. Determine Bullish vs Bearish
            bool isBullish = _candleInfo.Close >= _candleInfo.Open;
            Color candleColor = isBullish ? Color.Green : Color.Red;
            Brush bodyBrush = new SolidBrush(candleColor);
            Pen wickPen = new Pen(candleColor, 1);

            // 4. Draw the Wick (High to Low)
            g.DrawLine(wickPen, centerX, yHigh, centerX, yLow);

            // 5. Draw the Body
            float bodyTop = Math.Min(yOpen, yClose);
            float bodyHeight = Math.Max(1, Math.Abs(yOpen - yClose)); // Minimum 1px height
            g.FillRectangle(bodyBrush, centerX - (bodyWidth / 2), bodyTop, bodyWidth, bodyHeight);

            // 6. Draw the Time Label (The "08:00" part)
            if (_candleInfo.TimeLabel != null)
            {
                using (Font font = new Font("Segoe UI", 10, FontStyle.Bold))
                {
                    SizeF textSize = g.MeasureString(_candleInfo.TimeLabel, font);
                    // Position it at the bottom center of the box
                    g.DrawString(_candleInfo.TimeLabel, font, Brushes.White,
                                 centerX - (textSize.Width / 2), h - textSize.Height - 5);
                }
            }
        }

        private void picBar_Click(object sender, EventArgs e)
        {

        }
    }
}
