//+------------------------------------------------------------------+
//|                                                  Diagnostics.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
// Diagnostics.mqh
#ifndef __DIAGNOSTICS_MQH__
#define __DIAGNOSTICS_MQH__

input bool ShowDiagnostics = true;

void ShowDiagnosticsBox(string status, double adx, double adxPrev, double diPlus, double diMinus, double psar, double price) {
   if (!ShowDiagnostics) return;

   string name = "DiagnosticsLabel";
   string text = StringFormat(
      "PrecisionScout\nADX: %.2f (%s)\n+DI: %.2f\n-DI: %.2f\nDI Gap: %.2f\nPSAR: %.5f\nPrice: %.5f\nSignal: %s",
      adx,
      (adx >= adxPrev ? "↑" : "↓"),
      diPlus,
      diMinus,
      MathAbs(diPlus - diMinus),
      psar,
      price,
      status
   );

   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 20);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
}
#endif
