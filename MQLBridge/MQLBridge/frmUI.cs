using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MQLBridge
{
    public partial class frmUI : Form
    {
        // The second parameter is now a generic object
        public event Action<int, object> OnUICommand;
        private IntPtr _parentHandle = IntPtr.Zero;
        private const int WM_EXITSIZEMOVE = 0x0232;

        public frmUI()
        {
            InitializeComponent();
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

        public void btnTest_Click(object sender, EventArgs e)
        {
            string sDate = dtDate.Value.ToString("yyyy.MM.dd");
            OnUICommand?.Invoke(3, sDate);
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
            cboDays.SelectedIndex = 6;
            dtDate.Value = DateTime.Now;
            pnlBuySell.Visible = false;
            btnShowBuySell.PerformClick();
            Init_LotSize();
            cboTP.SelectedIndex = 0;
            cboSL.SelectedIndex = 0;
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
        }

        private void GetSettings()
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
            OnUICommand?.Invoke((int)UIMessageIDs.TradeHistory, dtDate.Value.ToString("yyyy.MM.dd"));
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
    }
}
