using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MQLBridge
{
    public partial class frmTradingHours : Form
    {
        //private WebView2 webView;
        public frmTradingHours()
        {
            InitializeComponent();
        }

        static frmTradingHours()
        {
            // Force IE11 Edge mode for better rendering
            RegistryKey key = Registry.CurrentUser.OpenSubKey(
                @"Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION", true);

            if (key != null)
            {
                string appName = Path.GetFileName(Application.ExecutablePath);
                key.SetValue(appName, 11001, RegistryValueKind.DWord);
                key.Close();
            }
        }

        private void frmTradingHours_Load(object sender, EventArgs e)
        {
            //webView.Navigate(GetEmbeddedHtml());
            InitializeWebView();
        }

        private async void InitializeWebView()
        {
            // Use data URI instead of DocumentText
            string html = GetEmbeddedHtml();
            webView.Navigate("about:blank");
            webView.Document.OpenNew(false);
            webView.Document.Write(html);
            webView.Refresh();
        }

        private string GetEmbeddedHtml()
        {
            var assembly = Assembly.GetExecutingAssembly();
            string resourceName = "MQLBridge.MarketHours_Min.html"; // Adjust namespace

            using (Stream stream = assembly.GetManifestResourceStream(resourceName))
            using (StreamReader reader = new StreamReader(stream))
            {
                return reader.ReadToEnd();
            }
        }
    }
}
