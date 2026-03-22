using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Windows.Forms.AxHost;

namespace MQLBridge
{
    public partial class frmTradeHistory : Form
    {
        private MT5TradeHistory tradeHistory;
        public frmUI parentForm;

        public frmTradeHistory()
        {
            InitializeComponent();
            tradeHistory = new MT5TradeHistory();
            Logger.Info("frmTradeHistory initialized");
        }

        private void frmTradeHistory_Load(object sender, EventArgs e)
        {
            lvwTrades.Items.Clear();
            tradeHistory.Trades.Clear();

            dtTo.Value = DateTime.Now;
            dtFrom.Value = DateTime.Now.AddDays(-7);
            Logger.Info("frmTradeHistory form loaded");
        }

        public void ShowTradeHistory(string rawData)
        {
            Logger.Info($"ShowTradeHistory called with {rawData?.Length ?? 0} bytes of data");
            tradeHistory.ParseFromMQL(rawData);

            //wait a bit for additional data to arrive
            tmrDelay.Stop();
            tmrDelay.Start();
        }

        private void btnRefresh_Click(object sender, EventArgs e)
        {
            // Validate date pickers
            if (dtFrom.Value > dtTo.Value)
            {
                Logger.Warning("Invalid date range: 'From' date is greater than 'To' date");
                MessageBox.Show("'From' date must be less than or equal to 'To' date.", "Invalid Date Range", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            //clear existing data   
            lvwTrades.Items.Clear();
            tradeHistory.Trades.Clear();

            // TODO: Implement refresh logic here
            string sRange = $"{dtFrom.Value:yyyy-MM-dd},{dtTo.Value:yyyy-MM-dd 23:59:59}";
            Logger.Info($"Refresh requested for date range: {sRange}");

            parentForm?.Send_OnUICommand((int)UIMessageIDs.TradeHistory, sRange);
        }

        public void SetParentForm(frmUI parent)
        {
            parentForm = parent;
        }

        private void tmrDelay_Tick(object sender, EventArgs e)
        {
            Logger.Info("tmrDelay_Tick triggered, updating ListView with trade history data");
            //display the data in the listview
            tmrDelay.Stop();
            lvwTrades.Items.Clear();
            lvwTrades.BeginUpdate();
            Logger.Info($"Updating ListView with {tradeHistory.Trades.Count} trades");
            try
            {
                Logger.Info("Iterating through trades to add to ListView");
                int rowIndex = 0;  // Track row for alternating colors
                foreach (var trade in tradeHistory.Trades)
                {
                    Logger.Debug("+Processing trade");

                    var item = new ListViewItem(trade.Ticket.ToString());
                    item.Tag = trade;  // Store the entire trade object for easy access later

                    // ALTERNATING ROW BACKGROUND COLOR
                    if (rowIndex % 2 == 0)
                        item.BackColor = Color.White;
                    else
                        item.BackColor = Color.LightGray;

                    item.UseItemStyleForSubItems = false;

                    // Add subitems in column order
                    item.SubItems.Add(trade.EntryTime.ToString("yyyy-MM-dd HH:mm:ss"));     // [1]
                    item.SubItems.Add(trade.Type);                                          // [2]
                    item.SubItems.Add(trade.Volume.ToString("F2"));                         // [3]
                    item.SubItems.Add(trade.EntryPrice.ToString("F2"));                     // [4]
                    item.SubItems.Add(trade.SL_pips.ToString());                            // [5]
                    item.SubItems.Add(trade.TP_pips.ToString());                            // [6]
                    item.SubItems.Add(trade.ExitTime.ToString("yyyy-MM-dd HH:mm:ss"));      // [7]
                    item.SubItems.Add(trade.ExitPrice.ToString("F2"));                      // [8]
                    item.SubItems.Add(trade.NetProfit.ToString("F2"));                      // [9] - colNetProfit
                    item.SubItems.Add(trade.Profit_pips.ToString());                        // [10]

                    // Set all subitem background colors to match row
                    Logger.Debug("Setting subitem background colors to match row");
                    foreach (ListViewItem.ListViewSubItem subItem in item.SubItems)
                    {
                        subItem.BackColor = item.BackColor;
                    }

                    // Set foreground colors using NUMERIC INDICES
                    Logger.Debug("Setting Net Profit subitem color based on value");
                    item.SubItems[9].ForeColor = trade.NetProfit >= 0 ? Color.Green : Color.Red;  // Index 9 = NetProfit

                    // Optional: Color-code ProfitPips too
                    item.SubItems[10].ForeColor = trade.Profit_pips >= 0 ? Color.Green : Color.Red;  // Index 10 = ProfitPips

                    // Optional: Color-code Type
                    item.SubItems[2].ForeColor = trade.Type == "buy" ? Color.Green : Color.Red;  // Index 2 = Type

                    lvwTrades.Items.Add(item);
                    rowIndex++;
                }
                Logger.Info($"Displayed {tradeHistory.Trades.Count} trades in ListView");
            }
            catch (Exception ex)
            {
                Logger.Error("Error while updating ListView with trade history data", ex);
                MessageBox.Show("An error occurred while displaying trade history data. Please check the logs for details.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                lvwTrades.EndUpdate();
            }
        }

        private void lvwTrades_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void lvwTrades_MouseDoubleClick(object sender, MouseEventArgs e)
        {
            var item = lvwTrades.GetItemAt(e.X, e.Y);
            if (item != null)
            {
                MT5Trade trade = item.Tag as MT5Trade;
                // Access the trade data
                if (trade != null)
                {
                    Logger.Info($"Double-clicked trade ticket: {trade.Ticket}");
                    string sParam = $"{trade.Ticket}, {trade.EntryTime:yyyy.MM.dd HH:mm}";
                    parentForm?.SendUICOmmand((int)UIMessageIDs.GoToTrade, sParam);
                }
            }
        }
    }

    public class MT5Trade
    {
        public long Ticket { get; set; }
        public string Type { get; set; } // 0=Buy, 1=Sell
        public double Volume { get; set; }
        public double EntryPrice { get; set; }
        public double ExitPrice { get; set; }
        public int SL_pips { get; set; }
        public int TP_pips { get; set; }
        public double NetProfit { get; set; }
        public int Profit_pips { get; set; }
        public DateTime EntryTime { get; set; }
        public DateTime ExitTime { get; set; }
    }

    public class MT5TradeHistory
    {
        public List<MT5Trade> Trades { get; set; }

        public MT5TradeHistory()
        {
            Trades = new List<MT5Trade>();
        }

        public void ParseFromMQL(string rawData)
        {
            Logger.Info("Parsing trade history data from MQL");
            Logger.Info(rawData);
            try
            {
                // Parse CSV or delimited format from MQL
                var lines = rawData.Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
                Logger.Info($"Parsing {lines.Length} lines from MQL data");

                foreach (var line in lines)
                {
                    Logger.Info($"{line}");
                    var trade = ParseTradeLine(line);
                    if (trade != null)
                        Trades.Add(trade);
                }
                Logger.Info($"Successfully parsed {Trades.Count} trades");
            }
            catch (Exception ex)
            {
                Logger.Error("Error in ParseFromMQL", ex);
            }
        }

        private MT5Trade ParseTradeLine(string line)
        {
            try
            {
                var fields = line.Split(',');
                if (fields.Length < 11)
                {
                    //TradeLogger.Log($"Invalid field count in trade line: expected 11, got {fields.Length}");
                    return null;
                }

                return new MT5Trade
                {
                    Ticket = long.Parse(fields[0]),
                    Type = fields[1].Trim(),
                    Volume = double.Parse(fields[2]),
                    EntryPrice = double.Parse(fields[3]),
                    ExitPrice = double.Parse(fields[4]),
                    SL_pips = int.Parse(fields[5]),
                    TP_pips = int.Parse(fields[6]),
                    NetProfit = double.Parse(fields[7]),
                    Profit_pips = int.Parse(fields[8]),
                    EntryTime = DateTime.Parse(fields[9]),
                    ExitTime = DateTime.Parse(fields[10])
                };
            }
            catch (Exception ex)
            {
                Logger.Error("Error parsing trade line", ex);
                return null;
            }
        }
    }

    
}
