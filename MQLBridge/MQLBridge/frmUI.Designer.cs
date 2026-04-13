namespace MQLBridge
{
    public partial class frmUI
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmUI));
            this.btnSetDate = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.dtDate = new System.Windows.Forms.DateTimePicker();
            this.label2 = new System.Windows.Forms.Label();
            this.cboDays = new System.Windows.Forms.ComboBox();
            this.lblCurrentBar = new System.Windows.Forms.Label();
            this.lblData2 = new System.Windows.Forms.Label();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.lblBO = new System.Windows.Forms.Label();
            this.lblBarTime = new System.Windows.Forms.Label();
            this.chkNotification = new System.Windows.Forms.CheckBox();
            this.label3 = new System.Windows.Forms.Label();
            this.toolTip1 = new System.Windows.Forms.ToolTip(this.components);
            this.btnSell = new System.Windows.Forms.Button();
            this.btnBuy = new System.Windows.Forms.Button();
            this.label4 = new System.Windows.Forms.Label();
            this.cboTP = new System.Windows.Forms.ComboBox();
            this.cboSL = new System.Windows.Forms.ComboBox();
            this.label5 = new System.Windows.Forms.Label();
            this.pnlBuySell = new System.Windows.Forms.Panel();
            this.lblAccountBalance = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.cboLotSize = new System.Windows.Forms.ComboBox();
            this.lblTimeLeft = new System.Windows.Forms.Label();
            this.btnMarketHours = new System.Windows.Forms.Button();
            this.btnShowBuySell = new System.Windows.Forms.Button();
            this.btnTradeHistory = new System.Windows.Forms.Button();
            this.btnChartMoveRight = new System.Windows.Forms.Button();
            this.btnChartMoveLeft = new System.Windows.Forms.Button();
            this.picBar = new System.Windows.Forms.PictureBox();
            this.btnDayCurrent = new System.Windows.Forms.Button();
            this.btnDayNext = new System.Windows.Forms.Button();
            this.btnDayPrevious = new System.Windows.Forms.Button();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.groupBox1.SuspendLayout();
            this.pnlBuySell.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picBar)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.SuspendLayout();
            // 
            // btnSetDate
            // 
            this.btnSetDate.Location = new System.Drawing.Point(342, 13);
            this.btnSetDate.Name = "btnSetDate";
            this.btnSetDate.Size = new System.Drawing.Size(66, 29);
            this.btnSetDate.TabIndex = 0;
            this.btnSetDate.Text = "Set";
            this.btnSetDate.UseVisualStyleBackColor = true;
            this.btnSetDate.Click += new System.EventHandler(this.btnSetDate_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(22, 19);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(43, 22);
            this.label1.TabIndex = 1;
            this.label1.Text = "Date";
            // 
            // dtDate
            // 
            this.dtDate.CalendarFont = new System.Drawing.Font("Cascadia Mono", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.dtDate.CustomFormat = "yyyy.MM.dd";
            this.dtDate.Font = new System.Drawing.Font("Century Gothic", 8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.dtDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtDate.Location = new System.Drawing.Point(126, 14);
            this.dtDate.Margin = new System.Windows.Forms.Padding(5, 3, 3, 3);
            this.dtDate.Name = "dtDate";
            this.dtDate.Size = new System.Drawing.Size(128, 27);
            this.dtDate.TabIndex = 2;
            this.dtDate.ValueChanged += new System.EventHandler(this.dtDate_ValueChanged);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(22, 63);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(63, 22);
            this.label2.TabIndex = 6;
            this.label2.Text = "S1 Days";
            // 
            // cboDays
            // 
            this.cboDays.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboDays.FormattingEnabled = true;
            this.cboDays.Location = new System.Drawing.Point(88, 60);
            this.cboDays.Name = "cboDays";
            this.cboDays.Size = new System.Drawing.Size(66, 30);
            this.cboDays.TabIndex = 7;
            this.cboDays.SelectedIndexChanged += new System.EventHandler(this.cboDays_SelectedIndexChanged);
            // 
            // lblCurrentBar
            // 
            this.lblCurrentBar.AutoSize = true;
            this.lblCurrentBar.Font = new System.Drawing.Font("Consolas", 8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblCurrentBar.Location = new System.Drawing.Point(17, 26);
            this.lblCurrentBar.Name = "lblCurrentBar";
            this.lblCurrentBar.Size = new System.Drawing.Size(27, 19);
            this.lblCurrentBar.TabIndex = 8;
            this.lblCurrentBar.Text = "[]";
            // 
            // lblData2
            // 
            this.lblData2.AutoSize = true;
            this.lblData2.Font = new System.Drawing.Font("Consolas", 8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblData2.Location = new System.Drawing.Point(17, 51);
            this.lblData2.Name = "lblData2";
            this.lblData2.Size = new System.Drawing.Size(27, 19);
            this.lblData2.TabIndex = 9;
            this.lblData2.Text = "[]";
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.lblBO);
            this.groupBox1.Controls.Add(this.picBar);
            this.groupBox1.Controls.Add(this.lblBarTime);
            this.groupBox1.Controls.Add(this.lblCurrentBar);
            this.groupBox1.Controls.Add(this.lblData2);
            this.groupBox1.Location = new System.Drawing.Point(26, 97);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(382, 86);
            this.groupBox1.TabIndex = 13;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Selected Bar Details";
            // 
            // lblBO
            // 
            this.lblBO.Font = new System.Drawing.Font("Consolas", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblBO.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(64)))), ((int)(((byte)(0)))));
            this.lblBO.Location = new System.Drawing.Point(234, -2);
            this.lblBO.Name = "lblBO";
            this.lblBO.Size = new System.Drawing.Size(80, 28);
            this.lblBO.TabIndex = 29;
            this.lblBO.Text = "BO 100%";
            this.lblBO.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // lblBarTime
            // 
            this.lblBarTime.Font = new System.Drawing.Font("Consolas", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblBarTime.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(64)))), ((int)(((byte)(0)))));
            this.lblBarTime.Location = new System.Drawing.Point(315, 1);
            this.lblBarTime.Name = "lblBarTime";
            this.lblBarTime.Size = new System.Drawing.Size(66, 22);
            this.lblBarTime.TabIndex = 28;
            this.lblBarTime.Text = "00:00";
            this.lblBarTime.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // chkNotification
            // 
            this.chkNotification.AutoSize = true;
            this.chkNotification.Checked = true;
            this.chkNotification.CheckState = System.Windows.Forms.CheckState.Checked;
            this.chkNotification.Location = new System.Drawing.Point(248, 62);
            this.chkNotification.Name = "chkNotification";
            this.chkNotification.Size = new System.Drawing.Size(160, 26);
            this.chkNotification.TabIndex = 14;
            this.chkNotification.Text = "Send Notification";
            this.chkNotification.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.chkNotification.UseVisualStyleBackColor = true;
            this.chkNotification.CheckedChanged += new System.EventHandler(this.chkNotification_CheckedChanged);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(22, 199);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(130, 22);
            this.label3.TabIndex = 15;
            this.label3.Text = "Chart Navigation";
            // 
            // btnSell
            // 
            this.btnSell.BackColor = System.Drawing.Color.IndianRed;
            this.btnSell.Font = new System.Drawing.Font("Trebuchet MS", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnSell.Location = new System.Drawing.Point(20, 160);
            this.btnSell.Name = "btnSell";
            this.btnSell.Size = new System.Drawing.Size(118, 56);
            this.btnSell.TabIndex = 19;
            this.btnSell.Text = "SELL";
            this.btnSell.UseVisualStyleBackColor = false;
            this.btnSell.Click += new System.EventHandler(this.btnSell_Click);
            // 
            // btnBuy
            // 
            this.btnBuy.BackColor = System.Drawing.Color.Green;
            this.btnBuy.Font = new System.Drawing.Font("Trebuchet MS", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnBuy.Location = new System.Drawing.Point(144, 160);
            this.btnBuy.Name = "btnBuy";
            this.btnBuy.Size = new System.Drawing.Size(118, 56);
            this.btnBuy.TabIndex = 20;
            this.btnBuy.Text = "BUY";
            this.btnBuy.UseVisualStyleBackColor = false;
            this.btnBuy.Click += new System.EventHandler(this.btnBuy_Click);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Font = new System.Drawing.Font("Trebuchet MS", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label4.Location = new System.Drawing.Point(15, 87);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(35, 26);
            this.label4.TabIndex = 21;
            this.label4.Text = "TP";
            // 
            // cboTP
            // 
            this.cboTP.Font = new System.Drawing.Font("Trebuchet MS", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cboTP.FormattingEnabled = true;
            this.cboTP.Location = new System.Drawing.Point(134, 83);
            this.cboTP.Name = "cboTP";
            this.cboTP.Size = new System.Drawing.Size(128, 31);
            this.cboTP.TabIndex = 22;
            // 
            // cboSL
            // 
            this.cboSL.Font = new System.Drawing.Font("Trebuchet MS", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cboSL.FormattingEnabled = true;
            this.cboSL.Location = new System.Drawing.Point(134, 119);
            this.cboSL.Name = "cboSL";
            this.cboSL.Size = new System.Drawing.Size(128, 31);
            this.cboSL.TabIndex = 24;
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Font = new System.Drawing.Font("Trebuchet MS", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label5.Location = new System.Drawing.Point(15, 124);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(32, 26);
            this.label5.TabIndex = 23;
            this.label5.Text = "SL";
            // 
            // pnlBuySell
            // 
            this.pnlBuySell.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.pnlBuySell.Controls.Add(this.lblAccountBalance);
            this.pnlBuySell.Controls.Add(this.label6);
            this.pnlBuySell.Controls.Add(this.cboLotSize);
            this.pnlBuySell.Controls.Add(this.lblTimeLeft);
            this.pnlBuySell.Controls.Add(this.label4);
            this.pnlBuySell.Controls.Add(this.cboSL);
            this.pnlBuySell.Controls.Add(this.btnSell);
            this.pnlBuySell.Controls.Add(this.label5);
            this.pnlBuySell.Controls.Add(this.btnBuy);
            this.pnlBuySell.Controls.Add(this.cboTP);
            this.pnlBuySell.Location = new System.Drawing.Point(465, 12);
            this.pnlBuySell.Name = "pnlBuySell";
            this.pnlBuySell.Size = new System.Drawing.Size(282, 222);
            this.pnlBuySell.TabIndex = 25;
            // 
            // lblAccountBalance
            // 
            this.lblAccountBalance.Font = new System.Drawing.Font("Trebuchet MS", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblAccountBalance.ForeColor = System.Drawing.SystemColors.ActiveCaptionText;
            this.lblAccountBalance.Location = new System.Drawing.Point(16, 6);
            this.lblAccountBalance.Name = "lblAccountBalance";
            this.lblAccountBalance.Size = new System.Drawing.Size(134, 26);
            this.lblAccountBalance.TabIndex = 28;
            this.lblAccountBalance.Text = "Bal: $0.00";
            this.lblAccountBalance.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Font = new System.Drawing.Font("Trebuchet MS", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label6.Location = new System.Drawing.Point(15, 48);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(84, 26);
            this.label6.TabIndex = 26;
            this.label6.Text = "Lot Size";
            // 
            // cboLotSize
            // 
            this.cboLotSize.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboLotSize.Font = new System.Drawing.Font("Trebuchet MS", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.cboLotSize.FormattingEnabled = true;
            this.cboLotSize.Location = new System.Drawing.Point(134, 44);
            this.cboLotSize.Name = "cboLotSize";
            this.cboLotSize.Size = new System.Drawing.Size(128, 31);
            this.cboLotSize.TabIndex = 27;
            // 
            // lblTimeLeft
            // 
            this.lblTimeLeft.Font = new System.Drawing.Font("Trebuchet MS", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblTimeLeft.ForeColor = System.Drawing.Color.Blue;
            this.lblTimeLeft.Location = new System.Drawing.Point(156, 6);
            this.lblTimeLeft.Name = "lblTimeLeft";
            this.lblTimeLeft.Size = new System.Drawing.Size(106, 26);
            this.lblTimeLeft.TabIndex = 25;
            this.lblTimeLeft.Text = "00:00";
            this.lblTimeLeft.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // btnMarketHours
            // 
            this.btnMarketHours.BackgroundImage = global::MQLBridge.Properties.Resources.trading;
            this.btnMarketHours.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnMarketHours.FlatAppearance.BorderColor = System.Drawing.SystemColors.Control;
            this.btnMarketHours.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnMarketHours.Location = new System.Drawing.Point(322, 189);
            this.btnMarketHours.Name = "btnMarketHours";
            this.btnMarketHours.Size = new System.Drawing.Size(40, 40);
            this.btnMarketHours.TabIndex = 27;
            this.btnMarketHours.TextAlign = System.Drawing.ContentAlignment.TopCenter;
            this.toolTip1.SetToolTip(this.btnMarketHours, "Trading Market Hours");
            this.btnMarketHours.UseVisualStyleBackColor = true;
            this.btnMarketHours.Click += new System.EventHandler(this.btnMarketHours_Click);
            // 
            // btnShowBuySell
            // 
            this.btnShowBuySell.BackgroundImage = global::MQLBridge.Properties.Resources.left;
            this.btnShowBuySell.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Zoom;
            this.btnShowBuySell.Location = new System.Drawing.Point(414, 63);
            this.btnShowBuySell.Name = "btnShowBuySell";
            this.btnShowBuySell.Size = new System.Drawing.Size(45, 82);
            this.btnShowBuySell.TabIndex = 26;
            this.btnShowBuySell.Tag = "Left";
            this.toolTip1.SetToolTip(this.btnShowBuySell, "Auto Trade");
            this.btnShowBuySell.UseVisualStyleBackColor = true;
            this.btnShowBuySell.Click += new System.EventHandler(this.btnShowBuySell_Click);
            // 
            // btnTradeHistory
            // 
            this.btnTradeHistory.BackgroundImage = global::MQLBridge.Properties.Resources.features;
            this.btnTradeHistory.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnTradeHistory.Cursor = System.Windows.Forms.Cursors.Hand;
            this.btnTradeHistory.FlatAppearance.BorderColor = System.Drawing.SystemColors.Control;
            this.btnTradeHistory.FlatAppearance.BorderSize = 0;
            this.btnTradeHistory.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnTradeHistory.Location = new System.Drawing.Point(368, 190);
            this.btnTradeHistory.Name = "btnTradeHistory";
            this.btnTradeHistory.Size = new System.Drawing.Size(40, 40);
            this.btnTradeHistory.TabIndex = 18;
            this.btnTradeHistory.TextAlign = System.Drawing.ContentAlignment.TopCenter;
            this.toolTip1.SetToolTip(this.btnTradeHistory, "Trade History");
            this.btnTradeHistory.UseVisualStyleBackColor = true;
            this.btnTradeHistory.Click += new System.EventHandler(this.btnTradeHistory_Click);
            // 
            // btnChartMoveRight
            // 
            this.btnChartMoveRight.BackgroundImage = global::MQLBridge.Properties.Resources.next1;
            this.btnChartMoveRight.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnChartMoveRight.Location = new System.Drawing.Point(208, 190);
            this.btnChartMoveRight.Name = "btnChartMoveRight";
            this.btnChartMoveRight.Size = new System.Drawing.Size(40, 40);
            this.btnChartMoveRight.TabIndex = 17;
            this.btnChartMoveRight.TextAlign = System.Drawing.ContentAlignment.TopCenter;
            this.toolTip1.SetToolTip(this.btnChartMoveRight, "Move one bar to the right");
            this.btnChartMoveRight.UseVisualStyleBackColor = true;
            this.btnChartMoveRight.Click += new System.EventHandler(this.btnChartMoveRight_Click);
            // 
            // btnChartMoveLeft
            // 
            this.btnChartMoveLeft.BackgroundImage = global::MQLBridge.Properties.Resources.back;
            this.btnChartMoveLeft.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnChartMoveLeft.Location = new System.Drawing.Point(158, 190);
            this.btnChartMoveLeft.Name = "btnChartMoveLeft";
            this.btnChartMoveLeft.Size = new System.Drawing.Size(40, 40);
            this.btnChartMoveLeft.TabIndex = 16;
            this.btnChartMoveLeft.TextAlign = System.Drawing.ContentAlignment.TopCenter;
            this.toolTip1.SetToolTip(this.btnChartMoveLeft, "Move one bar to the left.");
            this.btnChartMoveLeft.UseVisualStyleBackColor = true;
            this.btnChartMoveLeft.Click += new System.EventHandler(this.btnChartMoveLeft_Click);
            // 
            // picBar
            // 
            this.picBar.Location = new System.Drawing.Point(339, 25);
            this.picBar.Name = "picBar";
            this.picBar.Size = new System.Drawing.Size(36, 55);
            this.picBar.TabIndex = 28;
            this.picBar.TabStop = false;
            this.picBar.Click += new System.EventHandler(this.picBar_Click);
            this.picBar.Paint += new System.Windows.Forms.PaintEventHandler(this.picBar_Paint);
            // 
            // btnDayCurrent
            // 
            this.btnDayCurrent.BackgroundImage = global::MQLBridge.Properties.Resources.right;
            this.btnDayCurrent.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnDayCurrent.Location = new System.Drawing.Point(297, 14);
            this.btnDayCurrent.Margin = new System.Windows.Forms.Padding(0);
            this.btnDayCurrent.Name = "btnDayCurrent";
            this.btnDayCurrent.Size = new System.Drawing.Size(35, 29);
            this.btnDayCurrent.TabIndex = 5;
            this.btnDayCurrent.TextAlign = System.Drawing.ContentAlignment.TopCenter;
            this.btnDayCurrent.UseCompatibleTextRendering = true;
            this.btnDayCurrent.UseVisualStyleBackColor = true;
            this.btnDayCurrent.Click += new System.EventHandler(this.btnDayCurrent_Click);
            // 
            // btnDayNext
            // 
            this.btnDayNext.BackgroundImage = global::MQLBridge.Properties.Resources.right_arrow;
            this.btnDayNext.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnDayNext.Location = new System.Drawing.Point(259, 14);
            this.btnDayNext.Name = "btnDayNext";
            this.btnDayNext.Size = new System.Drawing.Size(30, 29);
            this.btnDayNext.TabIndex = 4;
            this.btnDayNext.TextAlign = System.Drawing.ContentAlignment.TopCenter;
            this.btnDayNext.UseVisualStyleBackColor = true;
            this.btnDayNext.Click += new System.EventHandler(this.btnDayNext_Click);
            // 
            // btnDayPrevious
            // 
            this.btnDayPrevious.BackgroundImage = global::MQLBridge.Properties.Resources.left_arrow__1_;
            this.btnDayPrevious.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnDayPrevious.Location = new System.Drawing.Point(88, 13);
            this.btnDayPrevious.Name = "btnDayPrevious";
            this.btnDayPrevious.Size = new System.Drawing.Size(30, 29);
            this.btnDayPrevious.TabIndex = 3;
            this.btnDayPrevious.TextAlign = System.Drawing.ContentAlignment.TopCenter;
            this.btnDayPrevious.UseVisualStyleBackColor = true;
            this.btnDayPrevious.Click += new System.EventHandler(this.btnDayPrevious_Click);
            // 
            // pictureBox1
            // 
            this.pictureBox1.BackgroundImage = global::MQLBridge.Properties.Resources.line;
            this.pictureBox1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.pictureBox1.Location = new System.Drawing.Point(415, 191);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(40, 40);
            this.pictureBox1.TabIndex = 28;
            this.pictureBox1.TabStop = false;
            this.toolTip1.SetToolTip(this.pictureBox1, resources.GetString("pictureBox1.ToolTip"));
            // 
            // frmUI
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(9F, 22F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(752, 239);
            this.Controls.Add(this.pictureBox1);
            this.Controls.Add(this.btnMarketHours);
            this.Controls.Add(this.btnShowBuySell);
            this.Controls.Add(this.pnlBuySell);
            this.Controls.Add(this.btnTradeHistory);
            this.Controls.Add(this.btnChartMoveRight);
            this.Controls.Add(this.btnChartMoveLeft);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.chkNotification);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.cboDays);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.btnDayCurrent);
            this.Controls.Add(this.btnDayNext);
            this.Controls.Add(this.btnDayPrevious);
            this.Controls.Add(this.dtDate);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.btnSetDate);
            this.Font = new System.Drawing.Font("Trebuchet MS", 8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedToolWindow;
            this.MaximizeBox = false;
            this.Name = "frmUI";
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "LA Backtest";
            this.TopMost = true;
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.frmUI_FormClosing);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.frmUI_FormClosed);
            this.Load += new System.EventHandler(this.frmUI_Load);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.pnlBuySell.ResumeLayout(false);
            this.pnlBuySell.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picBar)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnSetDate;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.DateTimePicker dtDate;
        private System.Windows.Forms.Button btnDayPrevious;
        private System.Windows.Forms.Button btnDayNext;
        private System.Windows.Forms.Button btnDayCurrent;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ComboBox cboDays;
        public System.Windows.Forms.Label lblCurrentBar;
        public System.Windows.Forms.Label lblData2;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.CheckBox chkNotification;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Button btnChartMoveLeft;
        private System.Windows.Forms.Button btnChartMoveRight;
        private System.Windows.Forms.Button btnTradeHistory;
        private System.Windows.Forms.ToolTip toolTip1;
        private System.Windows.Forms.Button btnSell;
        private System.Windows.Forms.Button btnBuy;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.ComboBox cboTP;
        private System.Windows.Forms.ComboBox cboSL;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Button btnShowBuySell;
        public System.Windows.Forms.Label lblTimeLeft;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.ComboBox cboLotSize;
        public System.Windows.Forms.Panel pnlBuySell;
        public System.Windows.Forms.Label lblAccountBalance;
        private System.Windows.Forms.Button btnMarketHours;
        public System.Windows.Forms.Label lblBarTime;
        private System.Windows.Forms.PictureBox picBar;
        public System.Windows.Forms.Label lblBO;
        private System.Windows.Forms.PictureBox pictureBox1;
    }
}