//+------------------------------------------------------------------+
//|                                                      MyPanel.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025"
#property strict

#include <Controls/Dialog.mqh>
#include <Controls/Label.mqh>
#include <Controls/Button.mqh>
#include <Controls/Edit.mqh>
#include <Controls/Defines.mqh>

class CMyPanel : public CAppDialog
{
public:
   int panel_left;
   CButton btnPrev, btnNext, btnSetDate;
   CEdit txtDate, txtS1Days;
   CLabel    lblDate, lblDays;
   // CEdit     m_edit;
   CButton   m_button;

public:
             CMyPanel(void) 
             {
               m_chart_id = 0;
               m_subwin = 0;
             };
            ~CMyPanel(void) {};

   virtual bool Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2);
   virtual bool Run(void) { return CAppDialog::Run(); }

protected:
   bool      CreateLabel(CLabel &m_label, string name, string text, int x, int y, int width, int height);
   bool      CreateEdit(CEdit &edit, string name, int x, int y, int width, int height, string default_text="");
   bool      CreateButton(CButton &button, string name, string label, int x, int y, int width, int height);
   void      OnClickButton(void);

   int       GetX1(CWnd &control);
   int       GetX2(CWnd &control);
   
   // Map events to the handler
   EVENT_MAP_BEGIN(CMyPanel)

   EVENT_MAP_END(CAppDialog)
};

//+------------------------------------------------------------------+
//| Initialize the panel and its controls                            |
//+------------------------------------------------------------------+
bool CMyPanel::Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2)
{
   if(!CAppDialog::Create(chart, name, subwin, x1, y1, x1+x2, y1+y2)) return false;
   
   Print("Creating MyPanel UI...", m_name);

   panel_left = x1+4;

   if(!CreateLabel(lblDate, "Date", "Date", 10, 10, 40, 30)) return false;
   if(!CreateButton(btnPrev, "Prev", "<", 80, 10, 20, 30)) return false;
   Print("Created Prev Button at X=", GetX1(btnPrev), " Y=", btnPrev.Top());

   datetime now = TimeCurrent();
   if(!CreateEdit(txtDate, "Date", GetX2(btnPrev) + 5, 10, 190, 30, TimeToString(now, TIME_DATE)))   return false;
   if(!CreateButton(btnNext, "Next", ">", GetX2(txtDate) + 5, 10, 20, 30)) return false;
   if(!CreateButton(btnSetDate, "SetDate", "Set", GetX2(btnNext) + 5, 10, 40, 30)) return false;

   if(!CreateLabel(lblDays, "DaysS1", "S1 Days", 10, 45, 40, 30)) return false;
   if(!CreateEdit(txtS1Days, "DaysToShow", GetX1(btnPrev), 45, 35, 30, ""))   return false;


   return true;
}

int CMyPanel::GetX1(CWnd &control)
{
   return control.Left() - panel_left;
}

int CMyPanel::GetX2(CWnd &control)
{
   return control.Right() - panel_left;
}


//+------------------------------------------------------------------+
//| Implementation of UI Elements                                    |
//+------------------------------------------------------------------+
bool CMyPanel::CreateLabel(CLabel &m_label, string name, string text, int x, int y, int width, int height)
{
   if(!m_label.Create(m_chart_id, "lbl"+name, m_subwin, x, y, x+width, y+height)) return false;
   if(!Add(m_label)) return false;
   m_label.Text(text);
   return true;
}

bool CMyPanel::CreateEdit(CEdit &edit, string name, int x, int y, int width, int height, string default_text="")
{
   if(!edit.Create(m_chart_id, "txt"+name, m_subwin, x, y, x+ width, y+height)) return false;
   if(!Add(edit)) return false;
   edit.Text(default_text);
   return true;
}

bool CMyPanel::CreateButton(CButton &button, string name, string label, int x, int y, int width, int height)
{
   if(!button.Create(m_chart_id, "btn"+name, m_subwin, x, y, x+width, y+height)) return false;
   if(!Add(button)) return false;
   button.Text(label);
   return true;
}



void CMyPanel::OnClickButton(void)
{
   // Print("Button clicked! Value: ", m_edit.Text());
}

void OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   // Pass all chart events to the UI class
   Print("Event received in MyPanel.mqh ", sparam);
   OnEvent(id, lparam, dparam, sparam);
}
// ... (Rest of the helper functions) ...

// void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
// {
//    // Pass all chart events to the UI class  
//    Print("Chart event: OBJECT CHANGE - Object: " + sparam);
   
// }