namespace MQLBridge
{
    partial class frmTradeHistory
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
            System.Windows.Forms.ListViewItem listViewItem1 = new System.Windows.Forms.ListViewItem(new string[] {
            "",
            "2026-03-15 01:15:19",
            "Sell",
            "0.02",
            "5152.74",
            "5132.74",
            "5156.74",
            "2026-03-15 01:15:19",
            "9999.99",
            "9999.99",
            "99999"}, -1);
            this.lvwTrades = new System.Windows.Forms.ListView();
            this.colTicket = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.colOpenTime = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.colType = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.colVolume = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.colEntryPrice = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.colSL = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.colTP = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.colExitTime = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.colExitPrice = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.colNetProfit = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.colProfitPips = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
            this.panel1 = new System.Windows.Forms.Panel();
            this.label5 = new System.Windows.Forms.Label();
            this.lblProfitPips = new System.Windows.Forms.Label();
            this.lblProfit = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.btnRefresh = new System.Windows.Forms.Button();
            this.dtTo = new System.Windows.Forms.DateTimePicker();
            this.label2 = new System.Windows.Forms.Label();
            this.dtFrom = new System.Windows.Forms.DateTimePicker();
            this.label1 = new System.Windows.Forms.Label();
            this.tmrDelay = new System.Windows.Forms.Timer(this.components);
            this.tableLayoutPanel1.SuspendLayout();
            this.panel1.SuspendLayout();
            this.SuspendLayout();
            // 
            // lvwTrades
            // 
            this.lvwTrades.Columns.AddRange(new System.Windows.Forms.ColumnHeader[] {
            this.colTicket,
            this.colOpenTime,
            this.colType,
            this.colVolume,
            this.colEntryPrice,
            this.colSL,
            this.colTP,
            this.colExitTime,
            this.colExitPrice,
            this.colNetProfit,
            this.colProfitPips});
            this.lvwTrades.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lvwTrades.FullRowSelect = true;
            this.lvwTrades.GridLines = true;
            this.lvwTrades.HideSelection = false;
            this.lvwTrades.Items.AddRange(new System.Windows.Forms.ListViewItem[] {
            listViewItem1});
            this.lvwTrades.Location = new System.Drawing.Point(3, 95);
            this.lvwTrades.MultiSelect = false;
            this.lvwTrades.Name = "lvwTrades";
            this.lvwTrades.Size = new System.Drawing.Size(947, 291);
            this.lvwTrades.TabIndex = 0;
            this.lvwTrades.UseCompatibleStateImageBehavior = false;
            this.lvwTrades.View = System.Windows.Forms.View.Details;
            this.lvwTrades.SelectedIndexChanged += new System.EventHandler(this.lvwTrades_SelectedIndexChanged);
            this.lvwTrades.MouseDoubleClick += new System.Windows.Forms.MouseEventHandler(this.lvwTrades_MouseDoubleClick);
            // 
            // colTicket
            // 
            this.colTicket.DisplayIndex = 1;
            this.colTicket.Text = "";
            this.colTicket.Width = 0;
            // 
            // colOpenTime
            // 
            this.colOpenTime.DisplayIndex = 0;
            this.colOpenTime.Text = "Time";
            this.colOpenTime.Width = 162;
            // 
            // colType
            // 
            this.colType.Text = "Type";
            this.colType.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.colType.Width = 52;
            // 
            // colVolume
            // 
            this.colVolume.Text = "Vol";
            this.colVolume.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.colVolume.Width = 53;
            // 
            // colEntryPrice
            // 
            this.colEntryPrice.Text = "Price";
            this.colEntryPrice.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.colEntryPrice.Width = 72;
            // 
            // colSL
            // 
            this.colSL.Text = "SL";
            this.colSL.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.colSL.Width = 72;
            // 
            // colTP
            // 
            this.colTP.Text = "TP";
            this.colTP.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.colTP.Width = 73;
            // 
            // colExitTime
            // 
            this.colExitTime.Text = "Time Close";
            this.colExitTime.Width = 163;
            // 
            // colExitPrice
            // 
            this.colExitPrice.Text = "Price";
            this.colExitPrice.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.colExitPrice.Width = 89;
            // 
            // colNetProfit
            // 
            this.colNetProfit.Text = "Profit";
            this.colNetProfit.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.colNetProfit.Width = 78;
            // 
            // colProfitPips
            // 
            this.colProfitPips.Text = "Pips";
            this.colProfitPips.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.colProfitPips.Width = 88;
            // 
            // tableLayoutPanel1
            // 
            this.tableLayoutPanel1.ColumnCount = 1;
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel1.Controls.Add(this.lvwTrades, 0, 1);
            this.tableLayoutPanel1.Controls.Add(this.panel1, 0, 0);
            this.tableLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel1.Location = new System.Drawing.Point(0, 0);
            this.tableLayoutPanel1.Name = "tableLayoutPanel1";
            this.tableLayoutPanel1.RowCount = 2;
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 92F));
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel1.Size = new System.Drawing.Size(953, 389);
            this.tableLayoutPanel1.TabIndex = 1;
            // 
            // panel1
            // 
            this.panel1.Controls.Add(this.label5);
            this.panel1.Controls.Add(this.lblProfitPips);
            this.panel1.Controls.Add(this.lblProfit);
            this.panel1.Controls.Add(this.label3);
            this.panel1.Controls.Add(this.btnRefresh);
            this.panel1.Controls.Add(this.dtTo);
            this.panel1.Controls.Add(this.label2);
            this.panel1.Controls.Add(this.dtFrom);
            this.panel1.Controls.Add(this.label1);
            this.panel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel1.Location = new System.Drawing.Point(3, 3);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(947, 86);
            this.panel1.TabIndex = 1;
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(900, 55);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(46, 20);
            this.label5.TabIndex = 8;
            this.label5.Text = "[pips]";
            // 
            // lblProfitPips
            // 
            this.lblProfitPips.Font = new System.Drawing.Font("Consolas", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblProfitPips.Location = new System.Drawing.Point(793, 55);
            this.lblProfitPips.Name = "lblProfitPips";
            this.lblProfitPips.Size = new System.Drawing.Size(109, 20);
            this.lblProfitPips.TabIndex = 7;
            this.lblProfitPips.Text = "0";
            this.lblProfitPips.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // lblProfit
            // 
            this.lblProfit.Font = new System.Drawing.Font("Consolas", 10F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblProfit.Location = new System.Drawing.Point(793, 34);
            this.lblProfit.Name = "lblProfit";
            this.lblProfit.Size = new System.Drawing.Size(109, 20);
            this.lblProfit.TabIndex = 6;
            this.lblProfit.Text = "0.00";
            this.lblProfit.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("Consolas", 9F, System.Drawing.FontStyle.Underline, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label3.Location = new System.Drawing.Point(774, 7);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(130, 22);
            this.label3.TabIndex = 5;
            this.label3.Text = "Total Profit";
            // 
            // btnRefresh
            // 
            this.btnRefresh.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnRefresh.Location = new System.Drawing.Point(480, 25);
            this.btnRefresh.Name = "btnRefresh";
            this.btnRefresh.Size = new System.Drawing.Size(107, 34);
            this.btnRefresh.TabIndex = 4;
            this.btnRefresh.Text = "Refresh";
            this.btnRefresh.UseVisualStyleBackColor = true;
            this.btnRefresh.Click += new System.EventHandler(this.btnRefresh_Click);
            // 
            // dtTo
            // 
            this.dtTo.CustomFormat = "yyyy.MM.dd";
            this.dtTo.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.dtTo.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtTo.Location = new System.Drawing.Point(304, 27);
            this.dtTo.Name = "dtTo";
            this.dtTo.Size = new System.Drawing.Size(165, 30);
            this.dtTo.TabIndex = 3;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(257, 32);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(36, 25);
            this.label2.TabIndex = 2;
            this.label2.Text = "To";
            // 
            // dtFrom
            // 
            this.dtFrom.CustomFormat = "yyyy.MM.dd";
            this.dtFrom.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.dtFrom.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtFrom.Location = new System.Drawing.Point(81, 27);
            this.dtFrom.Name = "dtFrom";
            this.dtFrom.Size = new System.Drawing.Size(165, 30);
            this.dtFrom.TabIndex = 1;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(13, 32);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(57, 25);
            this.label1.TabIndex = 0;
            this.label1.Text = "From";
            // 
            // tmrDelay
            // 
            this.tmrDelay.Interval = 1500;
            this.tmrDelay.Tick += new System.EventHandler(this.tmrDelay_Tick);
            // 
            // frmTradeHistory
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(9F, 20F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(953, 389);
            this.Controls.Add(this.tableLayoutPanel1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedToolWindow;
            this.Name = "frmTradeHistory";
            this.ShowInTaskbar = false;
            this.Text = "Trade History";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.frmTradeHistory_FormClosed);
            this.Load += new System.EventHandler(this.frmTradeHistory_Load);
            this.tableLayoutPanel1.ResumeLayout(false);
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.ListView lvwTrades;
        private System.Windows.Forms.ColumnHeader colOpenTime;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel1;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.ColumnHeader colTicket;
        private System.Windows.Forms.ColumnHeader colType;
        private System.Windows.Forms.ColumnHeader colVolume;
        private System.Windows.Forms.ColumnHeader colEntryPrice;
        private System.Windows.Forms.ColumnHeader colSL;
        private System.Windows.Forms.ColumnHeader colTP;
        private System.Windows.Forms.ColumnHeader colExitTime;
        private System.Windows.Forms.ColumnHeader colExitPrice;
        private System.Windows.Forms.ColumnHeader colNetProfit;
        private System.Windows.Forms.ColumnHeader colProfitPips;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button btnRefresh;
        private System.Windows.Forms.DateTimePicker dtTo;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.DateTimePicker dtFrom;
        private System.Windows.Forms.Timer tmrDelay;
        private System.Windows.Forms.Label lblProfit;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label lblProfitPips;
    }
}