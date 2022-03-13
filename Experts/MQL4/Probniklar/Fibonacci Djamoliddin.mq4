//+--------------------------------------------------------------------------------------------------+
//|                                                                       Fibonacci Djamoliddin.mq4  |
//|                                                               Strategiya muallifi:  Djamoliddin  |
//|                                                                    Dasturchi: Nematillo Ochilov  |
//+--------------------------------------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"//                                                       |
#property link      "https://t.me/MQLUZ"//                                                           |
//+--------------------------------------------------------------------------------------------------+
//|   Tashqi sozlamalar                                                                              |
//+--------------------------------------------------------------------------------------------------+
extern double Lots=0.01;  // Balans / Lotsize
extern int Profit=50;
//+--------------------------------------------------------------------------------------------------+
//|   Ichki sozlamalar
//+--------------------------------------------------------------------------------------------------+
double _Profit() {
    double BuyProfit = 0, SellProfit = 0;
    for(int i=0; i<OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol()) {
                if (OrderType() == OP_BUY) {
                    BuyProfit += OrderProfit();
                    }
                else if (OrderType() == OP_SELL) {
                    SellProfit += OrderProfit();
                    }
                }
            }
        }
    return(BuyProfit + SellProfit);
    }

void satr(string text) {
    long chart_ID = ChartID();
    string _name = "0";
    ObjectCreate(chart_ID,_name,OBJ_LABEL,0,0,0);
    ObjectSet(chart_ID,OBJPROP_XDISTANCE,70);
    ObjectSet(chart_ID,OBJPROP_YDISTANCE,180);
    ObjectSetInteger(chart_ID,_name,OBJPROP_COLOR,clrWhite);
    ObjectSetText(_name, text, 14, "Arial", clrWhite);
    ChartRedraw(chart_ID);
    }

void osb (double _Lot, double _BSL, double _BTP, int _Magic) {
    string strmagic = IntegerToString(_Magic);
    if (!OrderSend(Symbol(), OP_BUY, _Lot, Ask, 10, _BSL, _BTP, "Shamdon turi: " + strmagic, _Magic, 0, Blue))
        Print("OrderSend Buy " + strmagic + "-da muammo: ", GetLastError());
}

void oss (double _Lot, double _SSL, double _STP, int _Magic) {
    string strmagic = IntegerToString(_Magic);
    if (!OrderSend(Symbol(), OP_SELL, _Lot, Bid, 10, _SSL, _STP, "Shamdon turi: " + strmagic, _Magic, 0, Red))
        Print("OrderSend Sell " + strmagic + "-da muammo: ", GetLastError());
}

void om(double _stop)
{
    for (int cb = OrdersTotal(); cb >= 0; cb--)
    {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true)
        {
            if (!OrderModify(OrderTicket(), OrderOpenPrice(), _stop, OrderTakeProfit(), 0, Yellow))
                Print("OrderModify da muammo: ", GetLastError());
        }
    }
}

void oc()
{
    for (int cl = OrdersTotal(); cl >= 0; cl--)
    {
        if (OrderSelect(cl, SELECT_BY_POS, MODE_TRADES) == true)
        {
            if (OrderType() == OP_BUY)
            {
                if (!OrderClose(OrderTicket(),OrderLots(),Bid,10,Blue))
                    Print("OrderClose OP_BUYda muammo: ", GetLastError());
            }
            else if (OrderType() == OP_SELL)
            {
                if (!OrderClose(OrderTicket(),OrderLots(),Ask,10,Red))
                    Print("OrderClose OP_SELLda muammo: ", GetLastError());
            }
            else if (OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP ||
                OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT)
                {
                if (!OrderDelete(OrderTicket()))
                    Print("OrderDelete da muammo: ", GetLastError());
                }
        }
    }
}

int Error = 0;
int step = 0;
int signal = 2;
int day = 0;
int hour = 0;
int minute = 0;
double SL = 0.0;
double TP = 0.0;
double Prof = 0.0;
double high = 0.0;
double low = 0.0;
double length = 0.0;
double price50 = 0.0;
double price100 = 0.0;
double price161 = 0.0;
double price261 = 0.0;
datetime ordertime = TimeCurrent();

int start() {
    double PriceA=MarketInfo(Symbol(),MODE_ASK);
    double PriceB=MarketInfo(Symbol(),MODE_BID);
    double Open1=iOpen(Symbol(),PERIOD_CURRENT,1);
    double Close1=iClose(Symbol(),PERIOD_CURRENT,1);
    double High1=iHigh(Symbol(),PERIOD_CURRENT,1);
    double Low1=iLow(Symbol(),PERIOD_CURRENT,1);
    int DAY=TimeDay(TimeCurrent());
    int HOUR=TimeHour(TimeCurrent());
    int MINUTE=TimeMinute(TimeCurrent());
    Prof = _Profit();
    //+--------------------------------------------------------------------------------------------------+
    //|   Sotish yoki sotib olish     _Profit()                                                          |
    //+--------------------------------------------------------------------------------------------------+
    //satr("high: " + IntegerToString(high) + " low: " + IntegerToString(low) + " h-l: " + IntegerToString(high-low) + " length: " + DoubleToString(length) + " price50: " + DoubleToString(price50) + " lengthll: " + DoubleToString(low + length * 50));
    string tt = "s " + IntegerToString(signal) + " price50: " + IntegerToString(price50) + " price100: " + IntegerToString(price100) + " price161: " + IntegerToString(price161);
    satr(tt);
//    if (OrdersTotal() > 0)
//    {
//        //satr("Balans: " + IntegerToString(AccountBalance()) + " Foyda: " + IntegerToString(Prof) + "$ Bitimlar soni: " + IntegerToString(OrdersTotal()));
//    }
    if (OrdersTotal() < 1 && hour != HOUR)
    {
        if (signal == 2)
        {
            if (
                iOpen(Symbol(),PERIOD_CURRENT,1) > iClose(Symbol(),PERIOD_CURRENT,1) &&
                iOpen(Symbol(),PERIOD_CURRENT,2) > iClose(Symbol(),PERIOD_CURRENT,2) &&
                iOpen(Symbol(),PERIOD_CURRENT,3) > iClose(Symbol(),PERIOD_CURRENT,3)
                )
            {
                high = iOpen(Symbol(),PERIOD_CURRENT,3);
                low = iClose(Symbol(),PERIOD_CURRENT,1);
                length = (high - low) / 100;
                if (length > 0.1)
                {
                    signal = 0;
//                    price50 = NormalizeDouble(low + length * 50,Digits);
//                    price100 = NormalizeDouble(low + length * 100,Digits);
//                    price161 = NormalizeDouble(low + length * 161,Digits);
//                    price261 = NormalizeDouble(low + length * 261,Digits);

                    price50 = low + length * 50;
                    price100 = low + length * 100;
                    price161 = low + length * 161;
                    price261 = low + length * 261;
                }
            }
            else if (
                iOpen(Symbol(),PERIOD_CURRENT,1) < iClose(Symbol(),PERIOD_CURRENT,1) &&
                iOpen(Symbol(),PERIOD_CURRENT,2) < iClose(Symbol(),PERIOD_CURRENT,2) &&
                iOpen(Symbol(),PERIOD_CURRENT,3) < iClose(Symbol(),PERIOD_CURRENT,3)
                )
            {
                high = iClose(Symbol(),PERIOD_CURRENT,1);
                low = iOpen(Symbol(),PERIOD_CURRENT,3);
                length = (high - low) / 100;
                if (length > 0.1)
                {
                    signal = 1;
//                    price50 = NormalizeDouble(high - length * 50,Digits);
//                    price100 = NormalizeDouble(high - length * 100,Digits);
//                    price161 = NormalizeDouble(high - length * 161,Digits);
//                    price261 = NormalizeDouble(high - length * 261,Digits);

                    price50 = high - length * 50;
                    price100 = high - length * 100;
                    price161 = high - length * 161;
                    price261 = high - length * 261;
                }
            }
        }
        else if (signal == 0)
        {
            signal = 2;
            hour = HOUR;
            if (!OrderSend(Symbol(), OP_BUYLIMIT, Lots, price100, 30, price50, price161, "Buy", 0, 0, Blue))
                Print(tt);
                Error = 1;
                //Print("OrderSend BUYLIMITda muammo: ", GetLastError());
        }
        else if (signal == 1)
        {
            signal = 2;
            hour = HOUR;
            if (!OrderSend(Symbol(), OP_SELLLIMIT, Lots, price100, 30, price50, price161, "Sell", 1, 0, Red))
                Print(tt);
                Error = 1;
                //Print("OrderSend SELLLIMITda muammo: ", GetLastError());

        }
    }
//    if (Error == 1)
//    {
//        int GLE = GetLastError();
//        if (GLE == 130)
//        {
//            Print(tt);
//            RefreshRates();
//            Error = 0;
//        }
//    }
    return(0);}
