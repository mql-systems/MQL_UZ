//+--------------------------------------------------------------------------------------------------+
//|                                                                                Signalchilar.mq4  |
//|                                                          Strategiya muallifi: Nematillo Ochilov  |
//|                                                                    Dasturchi: Nematillo Ochilov  |
//+--------------------------------------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"//                                                       |
#property link      "https://t.me/MQLUZ"//                                                           |
//+--------------------------------------------------------------------------------------------------+
//|   Tashqi sozlamalar                                                                              |
//+--------------------------------------------------------------------------------------------------+
extern int LotSize=10000;  // Balans / Lotsize
extern int OpenPrice=20;
extern int StopLoss=1400;
extern int TakeProfit=200;
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

int step = 0, Magic = 1, signal, day, hour, minute;
double SL, TP, Lots, Prof, dol;
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
    //satr(OrdersTotal());
    if (OrdersTotal() > 0)
    {
        satr("Balans: " + IntegerToString(AccountBalance()) + " Foyda: " + IntegerToString(Prof) + "$ Bitimlar soni: " + IntegerToString(OrdersTotal()));
        if (Prof > (AccountBalance()/100*Profit) || HOUR == 23)
            {
                oc();
            }
    }
    else if (OrdersTotal() < 1 && 1 <= HOUR && day != DAY)
    {
        Lots = AccountBalance()/LotSize;
        dol=iCustom(NULL,PERIOD_CURRENT,"Daily open line",0,0);
        if (Open1 < Close1 && PriceA > dol)
        {
            day = DAY;
            SL = dol - StopLoss * Point;
            TP = dol + TakeProfit  * Point;
            if (!OrderSend(Symbol(), OP_BUYLIMIT, Lots, Bid - OpenPrice * Point, 10, SL, TP, "NO savdo ", 0, 0, Blue))
                Print("OrderSend BUYLIMITda muammo: ", GetLastError());
            // osb(Lots, SL, TP, 0);
        }
        else if (Open1 > Close1 && PriceB < dol)
        {
            day = DAY;
            SL = dol + StopLoss * Point;
            TP = dol - TakeProfit  * Point;
            if (!OrderSend(Symbol(), OP_SELLLIMIT, Lots, Ask + OpenPrice * Point, 10, SL, TP, "NO savdo ", 1, 0, Red))
                Print("OrderSend SELLLIMITda muammo: ", GetLastError());
            // oss(Lots, SL, TP, 1);
        }
    }
    return(0);}
