//+------------------------------------------------------------------+
//|                                                   CalcProfit.mqh |
//|                     Nematillo Ochilov and Almaz (DiamondSystems) |
//|                                               https://t.me/MQLUZ |
//+------------------------------------------------------------------+
#property copyright "Nematillo Ochilov and Almaz (DiamondSystems)"
#property link      "https://t.me/MQLUZ"

//+------------------------------------------------------------------+
//| Calculate profit                                                 |
//+------------------------------------------------------------------+
double Calc_Profit(string symbol = NULL, int magicNumber = NULL)
{
   double buyProfit  = 0,
          sellProfit = 0;

   #ifdef __MQL5__
      for (int i=0; i<PositionsTotal(); i++)
      {
         if (symbol != NULL)
         {
            if (PositionGetSymbol(i) != symbol)
               continue;
         }
         else if (PositionGetTicket(i) == 0)
            continue;
         
         if (magicNumber == NULL || magicNumber == (int)PositionGetInteger(POSITION_MAGIC))
         {
            switch ((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE))
            {
               case POSITION_TYPE_BUY:  buyProfit  += PositionGetDouble(POSITION_PROFIT); break;
               case POSITION_TYPE_SELL: sellProfit += PositionGetDouble(POSITION_PROFIT); break;
            }
         }
      }
   #else
      for (int i=0; i<OrdersTotal(); i++)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
             (symbol == NULL || symbol == OrderSymbol()) &&
             (magicNumber == NULL || magicNumber == OrderMagicNumber()) )
         {
             if (OrderType() == OP_BUY)
                 buyProfit += OrderProfit();
             else if (OrderType() == OP_SELL)
                 sellProfit += OrderProfit();
         }
      }
   #endif
   
   return (buyProfit + sellProfit);
}
