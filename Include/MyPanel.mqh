//+------------------------------------------------------------------+
//|                                                      MyPanel.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025"
#property strict

#include <Controls/Dialog.mqh>
#include <Controls/Label.mqh>
#include <Controls/Button.mqh>
#include <Controls/Edit.mqh>

class CMyPanel : public CAppDialog
{
private:
   CLabel    m_label;
   CEdit     m_edit;
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
   bool      CreateLabel(void);
   bool      CreateEdit(void);
   bool      CreateButton(void);
   void      OnClickButton(void);
   
   // Map events to the handler
   EVENT_MAP_BEGIN(CMyPanel)

   EVENT_MAP_END(CAppDialog)
};

//+------------------------------------------------------------------+
//| Implementation of UI Elements                                    |
//+------------------------------------------------------------------+
bool CMyPanel::CreateLabel(void)
{
   if(!m_label.Create(m_chart_id, m_name+"Label", m_subwin, 10, 10, 150, 30)) return false;
   if(!Add(m_label)) return false;
   m_label.Text("Enter Parameter:");
   return true;
}

bool CMyPanel::CreateEdit(void)
{
   if(!m_edit.Create(m_chart_id, m_name+"Edit", m_subwin, 10, 40, 190, 60)) return false;
   if(!Add(m_edit)) return false;
   m_edit.Text("Default Value");
   return true;
}

bool CMyPanel::CreateButton(void)
{
   if(!m_button.Create(m_chart_id, m_name+"Button", m_subwin, 10, 70, 100, 100)) return false;
   if(!Add(m_button)) return false;
   m_button.Text("Execute");
   return true;
}

//+------------------------------------------------------------------+
//| Initialize the panel and its controls                            |
//+------------------------------------------------------------------+
bool CMyPanel::Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2)
{
   if(!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2)) return false;
   
   if(!CreateLabel())  return false;
   if(!CreateEdit())   return false;
   if(!CreateButton()) return false;
   
   return true;
}

void CMyPanel::OnClickButton(void)
{
   Print("Button clicked! Value: ", m_edit.Text());
}

void OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   // Pass all chart events to the UI class
   Print("Event received in MyPanel.mqh ", sparam);
   OnEvent(id, lparam, dparam, sparam);
}
// ... (Rest of the helper functions) ...