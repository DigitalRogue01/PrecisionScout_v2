
//+------------------------------------------------------------------+
//|                                            PrecisionScout_v2.mq4 |
//|                           Custom Expert Advisor by Jim & GPT-4  |
//+------------------------------------------------------------------+
#property strict

#include <LotSize_Calculations.mqh>
#include <OpenTrade.mqh>
#include <TradeManagement.mqh>
#include <Diagnostics.mqh>
#include <ErrorHandler.mqh>
#include <TradeLogger.mqh>
#include <CandleDirectionPredictor.mqh>

//--- input parameters
input double RiskPercent        = 2.0;
input double ATRMultiplier      = 1.5;
input double PSAR_Step          = 0.06;
input double PSAR_Max           = 0.2;
input int    ATR_Period         = 14;
input int    ADX_Period         = 14;
input double ADX_Minimum        = 37.5;
input double MinDIDistance      = 10.0;
input int    Slippage           = 3;
input bool   EnableDebug        = true;
input int    MagicNumber        = 123456;

//--- internal variables
datetime lastTradeTime = 0;

int OnInit()
  {
   if (EnableDebug)
      Print("PrecisionScout_v2 initialized.");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   Diagnostics_Cleanup();
  }

void OnTick()
  {
   if(!NewCandle()) return;

   double atr = iATR(Symbol(), 0, ATR_Period, 0);
   double psar = iSAR(Symbol(), 0, PSAR_Step, PSAR_Max, 0);
   double adx = iADX(Symbol(), 0, ADX_Period, PRICE_CLOSE, MODE_MAIN, 0);
   double diPlus = iADX(Symbol(), 0, ADX_Period, PRICE_CLOSE, MODE_PLUSDI, 0);
   double diMinus = iADX(Symbol(), 0, ADX_Period, PRICE_CLOSE, MODE_MINUSDI, 0);
   double diDiff = MathAbs(diPlus - diMinus);

   if(EnableDebug)
      Print("ADX=", adx, " DI+=", diPlus, " DI-=", diMinus, " PSAR=", psar, " ATR=", atr);

   if(adx < ADX_Minimum || diDiff < MinDIDistance) return;

   int direction = (diPlus > diMinus) ? OP_BUY : OP_SELL;

   if(Time[0] == lastTradeTime) return;

   double stopLossPoints = atr * ATRMultiplier / Point;
   double lotSize = CalculateLotSize(RiskPercent, stopLossPoints);

   if(Open_Trade(direction, lotSize, stopLossPoints, Slippage, MagicNumber))
     {
      lastTradeTime = Time[0];
      if(EnableDebug) Print("Trade opened. Direction: ", (direction==OP_BUY ? "BUY" : "SELL"));
     }

   Trade_Manage(MagicNumber, PSAR_Step, PSAR_Max, ATRMultiplier, atr);
   Diagnostics_Update(adx, diPlus, diMinus, psar, atr, direction, AccountBalance(), EnableDebug);
  }

bool NewCandle()
  {
   static datetime lastCandleTime = 0;
   if(Time[0] != lastCandleTime)
     {
      lastCandleTime = Time[0];
      return true;
     }
   return false;
  }
