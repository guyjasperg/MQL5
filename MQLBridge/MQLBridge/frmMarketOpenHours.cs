using System;
using System.Drawing;
using System.Windows.Forms;
using System.Collections.Generic;

namespace MQLBridge
{
    public partial class frmMarketOpenHours : Form
    {
        private PictureBox chartBox;
        private Timer refreshTimer;
        public frmUI parentForm;

        // Define Market Sessions (Start Hour, Duration)
        private readonly List<MarketSession> sessions = new List<MarketSession>
        {
            new MarketSession("New York", 20, 9, Color.FromArgb(225, 112, 85)),
            new MarketSession("London", 15, 9, Color.FromArgb(253, 203, 110)),
            new MarketSession("Tokyo", 7, 9, Color.FromArgb(9, 132, 227)),
            new MarketSession("Sydney", 5, 9, Color.FromArgb(0, 184, 148)),
        };
        public frmMarketOpenHours()
        {
            //InitializeComponent();
            this.Text = "Forex Market Monitor";
            this.Size = new Size(800, 400);
            this.BackColor = Color.FromArgb(30, 30, 30);

            chartBox = new PictureBox
            {
                Dock = DockStyle.Fill,
                BackColor = Color.FromArgb(45, 45, 45)
            };

            chartBox.Paint += ChartBox_Paint;
            this.Controls.Add(chartBox);

            // Update every minute to move the "Current Time" bar
            refreshTimer = new Timer { Interval = 60000 };
            refreshTimer.Tick += (s, e) => chartBox.Invalidate();
            refreshTimer.Start();
        }

        private void ChartBox_Paint(object sender, PaintEventArgs e)
        {
            Graphics g = e.Graphics;
            g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;

            // Layout Constants
            int margin = 60;
            int labelWidth = 100;
            int chartWidth = chartBox.Width - labelWidth - (margin * 2);
            int rowHeight = 40;
            int startY = 80; // Pushed down slightly for the extra labels
            float pixelsPerHour = chartWidth / 24f;

            // --- 1. Draw Hour Labels (Local & Cyprus) ---

            // Get Cyprus Time Info
            TimeZoneInfo cyprusZone = TimeZoneInfo.FindSystemTimeZoneById("GTB Standard Time");
            DateTime cyprusTime = TimeZoneInfo.ConvertTime(DateTime.Now, cyprusZone);
            int offsetDiff = (int)(cyprusTime.Hour - DateTime.Now.Hour);

            for (int i = 0; i <= 24; i += 2)
            {
                float x = labelWidth + margin + (i * pixelsPerHour);

                // Local Time Label (Top)
                g.DrawString(i.ToString("00"), this.Font, Brushes.Gray, x - 10, 25);

                // Cyprus Time Label (Bottom - shifted by offset)
                int cypHour = (i + offsetDiff + 24) % 24;
                if (i == 0)
                    cypHour = 20;
                g.DrawString(cypHour.ToString("00"), new Font(this.Font.FontFamily, 7), Brushes.CadetBlue, x - 8, 40);

                // Grid Lines
                g.DrawLine(new Pen(Color.FromArgb(60, 60, 60)), x, 55, x, startY + (sessions.Count * rowHeight));
            }

            // Legend for the scales
            g.DrawString("Local:", new Font(this.Font, FontStyle.Italic), Brushes.Gray, margin - 10, 25);
            g.DrawString("Cyprus:", new Font(this.Font, FontStyle.Italic), Brushes.CadetBlue, margin - 10, 40);

            // --- 2. Draw Market Bars (Same logic as before) ---
            for (int i = 0; i < sessions.Count; i++)
            {
                var session = sessions[i];
                int y = startY + (i * rowHeight);

                g.DrawString(session.Name, new Font("Segoe UI", 9, FontStyle.Bold), Brushes.WhiteSmoke, margin, y + 5);
                g.FillRectangle(new SolidBrush(Color.FromArgb(45, 45, 45)), labelWidth + margin, y, chartWidth, 20);

                float xStart = labelWidth + margin + (session.StartHour * pixelsPerHour);
                float totalWidth = session.Duration * pixelsPerHour;

                if (session.StartHour + session.Duration > 24)
                {
                    float widthA = (24 - session.StartHour) * pixelsPerHour;
                    g.FillRectangle(new SolidBrush(session.BarColor), xStart, y, widthA, 20);
                    float widthB = totalWidth - widthA;
                    g.FillRectangle(new SolidBrush(session.BarColor), labelWidth + margin, y, widthB, 20);
                }
                else
                {
                    g.FillRectangle(new SolidBrush(session.BarColor), xStart, y, totalWidth, 20);
                }
            }

            // --- 3. Current Time Indicator ---
            DateTime now = DateTime.Now;
            float totalMinutes = (now.Hour * 60) + now.Minute;
            float currentTimeX = labelWidth + margin + (totalMinutes * (chartWidth / 1440f));

            using (Pen nowPen = new Pen(Color.Tomato, 2))
            {
                g.DrawLine(nowPen, currentTimeX, 20, currentTimeX, startY + (sessions.Count * rowHeight) + 10);
                g.DrawString($"NOW ({cyprusTime:HH:mm} CYP)", new Font("Segoe UI", 7, FontStyle.Bold), Brushes.Tomato, currentTimeX - 25, 5);
            }
        }
    }

    public class MarketSession
    {
        public string Name { get; set; }
        public int StartHour { get; set; }
        public int Duration { get; set; }
        public Color BarColor { get; set; }

        public MarketSession(string name, int start, int duration, Color color)
        {
            Name = name;
            StartHour = start;
            Duration = duration;
            BarColor = color;
        }
    }
}
