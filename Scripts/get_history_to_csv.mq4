//-*- coding: utf-8 -*-
//+--------------------------------------------------------------------------------------------------+
//|                                                            Program name: get_history_to_csv.mq4  |
//|                                                                Script author: Nematillo Ochilov  |
//|                                                                   Programmer: Nematillo Ochilov  |
//+--------------------------------------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"//                                                       |
#property link      "https://t.me/MQLUZ"//                                                           |
//+--------------------------------------------------------------------------------------------------+
#property show_inputs
extern string symbol_name = "XAUUSD";

// list of timeframes
int minutes[9] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

// a function that uploads the history of quotations to a csv file
void get_history(string iSymbol)
{
    for (int i = 0; i <= 8 ; i++)
    {
        int iPeriod = minutes[i];
        int file = FileOpen(IntegerToString(iPeriod) + ".csv", FILE_CSV | FILE_ANSI | FILE_WRITE, ',');
        FileWrite(file, "Time", "Open", "High", "Low", "Close", "Volume");
        int bar = iBars(iSymbol, iPeriod);
        for (int iBar = bar - 1; iBar >= 0 ; iBar--)
        {
            string date = TimeToString(iTime(iSymbol, iPeriod, iBar), TIME_DATE|TIME_MINUTES);
            double open = iOpen(iSymbol, iPeriod, iBar);
            double high = iHigh(iSymbol, iPeriod, iBar);
            double low = iLow(iSymbol, iPeriod, iBar);
            double close = iClose(iSymbol, iPeriod, iBar);
            double volume = iVolume(iSymbol, iPeriod, iBar);
            FileWrite(file, date, open, high, low, close, volume);
        }
        FileClose(file);
    }
}

// main function
void start()
{
    double d = SymbolInfoDouble(symbol_name, SYMBOL_ASK);
    int error_code=GetLastError();
    if (error_code == 0)
    {
        get_history(symbol_name);
        Alert("LOADING COMPLETE");
    }
    else if (error_code == 4106)
    {
        Alert("Unknown symbol");
    }
    else
    {
        Alert("Error");
    }
}
