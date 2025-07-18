#ifndef __LOT_SIZE_CALCULATIONS_MQH__
#define __LOT_SIZE_CALCULATIONS_MQH__

double CalculateLotSize(double stopLossPrice, bool isBuy)
{
    // --- Get ATR-based stop loss distance ---
    double atr = iATR(Symbol(), 0, ATRPeriod, 0);
    double stopLossDistance = atr * ATRMultiplier;

    // --- Calculate risk and tick value ---
    double riskAmount = AccountBalance() * RiskPercent / 100.0;
    double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);

    // Convert pip distance to monetary value
    double pipValue = stopLossDistance / Point * tickValue;

    if (pipValue <= 0)
    {
        Print("Invalid pip value for symbol ", Symbol());
        return 0.0;
    }

    // --- Lot size calculation ---
    double lotSize = riskAmount / pipValue;

    // --- Apply broker constraints ---
    double minLot = MarketInfo(Symbol(), MODE_MINLOT);
    double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);

    lotSize = MathFloor(lotSize / lotStep) * lotStep;
    if (lotSize < minLot) lotSize = minLot;

    return lotSize;
}

#endif
