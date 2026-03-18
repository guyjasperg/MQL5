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
            this.colTimeOpen = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
            this.panel1 = new System.Windows.Forms.Panel();
            this.colTicket = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.colType = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.colVolume = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.colPriceOpen = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.colSL = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.colTP = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.colTimeClose = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.colPriceClose = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.colProfit = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.colProfitPips = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.tableLayoutPanel1.SuspendLayout();
            this.SuspendLayout();
            // 
            // lvwTrades
            // 
            this.lvwTrades.Columns.AddRange(new System.Windows.Forms.ColumnHeader[] {
            this.colTicket,
            this.colTimeOpen,
            this.colType,
            this.colVolume,
            this.colPriceOpen,
            this.colSL,
            this.colTP,
            this.colTimeClose,
            this.colPriceClose,
            this.colProfit,
            this.colProfitPips});
            this.lvwTrades.Dock = System.Windows.Forms.DockStyle.Fill;
            this.lvwTrades.FullRowSelect = true;
            this.lvwTrades.GridLines = true;
            this.lvwTrades.HideSelection = false;
            this.lvwTrades.HoverSelection = true;
            this.lvwTrades.Items.AddRange(new System.Windows.Forms.ListViewItem[] {
            listViewItem1});
            this.lvwTrades.Location = new System.Drawing.Point(3, 95);
            this.lvwTrades.MultiSelect = false;
            this.lvwTrades.Name = "lvwTrades";
            this.lvwTrades.Size = new System.Drawing.Size(947, 291);
            this.lvwTrades.TabIndex = 0;
            this.lvwTrades.UseCompatibleStateImageBehavior = false;
            this.lvwTrades.View = System.Windows.Forms.View.Details;
            // 
            // colTimeOpen
            // 
            this.colTimeOpen.DisplayIndex = 0;
            this.colTimeOpen.Text = "Time";
            this.colTimeOpen.Width = 162;
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
            this.panel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel1.Location = new System.Drawing.Point(3, 3);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(947, 86);
            this.panel1.TabIndex = 1;
            // 
            // colTicket
            // 
            this.colTicket.DisplayIndex = 1;
            this.colTicket.Text = "";
            this.colTicket.Width = 0;
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
            // colPriceOpen
            // 
            this.colPriceOpen.Text = "Price";
            this.colPriceOpen.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.colPriceOpen.Width = 72;
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
            // colTimeClose
            // 
            this.colTimeClose.Text = "Time Close";
            this.colTimeClose.Width = 163;
            // 
            // colPriceClose
            // 
            this.colPriceClose.Text = "Price Close";
            this.colPriceClose.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.colPriceClose.Width = 89;
            // 
            // colProfit
            // 
            this.colProfit.Text = "Profit";
            this.colProfit.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.colProfit.Width = 78;
            // 
            // colProfitPips
            // 
            this.colProfitPips.Text = "Pips";
            this.colProfitPips.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.colProfitPips.Width = 88;
            // 
            // frmTradeHistory
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(9F, 20F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(953, 389);
            this.Controls.Add(this.tableLayoutPanel1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedToolWindow;
            this.Name = "frmTradeHistory";
            this.Text = "Trade History";
            this.Load += new System.EventHandler(this.frmTradeHistory_Load);
            this.tableLayoutPanel1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.ListView lvwTrades;
        private System.Windows.Forms.ColumnHeader colTimeOpen;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel1;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.ColumnHeader colTicket;
        private System.Windows.Forms.ColumnHeader colType;
        private System.Windows.Forms.ColumnHeader colVolume;
        private System.Windows.Forms.ColumnHeader colPriceOpen;
        private System.Windows.Forms.ColumnHeader colSL;
        private System.Windows.Forms.ColumnHeader colTP;
        private System.Windows.Forms.ColumnHeader colTimeClose;
        private System.Windows.Forms.ColumnHeader colPriceClose;
        private System.Windows.Forms.ColumnHeader colProfit;
        private System.Windows.Forms.ColumnHeader colProfitPips;
    }
}