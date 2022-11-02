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

extern string start_date = "2018.01.01";
extern string end_date = "2022.11.01";
datetime sd = StringToTime(start_date);
datetime ed = StringToTime(end_date);

// list of timeframes
int minutes[9] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

// a function that downloads the history of quotations to a csv file
void get_history()
{
    for (int i = 0; i <= 8 ; i++)
    {
        int iPeriod = minutes[i];
        MqlRates rates[];
        CopyRates(Symbol(), iPeriod, sd, ed, rates);
        int bar = ArrayRange(rates, 0);
        int file = FileOpen(Symbol() + IntegerToString(iPeriod) + ".csv", FILE_CSV | FILE_WRITE, ',');
        FileWrite(file, "Time", "Open", "High", "Low", "Close", "Volume");
        string iSymbol = Symbol();
        for (int iBar = 0; iBar < bar ; iBar++)
        {
            string date = TimeToString(rates[iBar].time, TIME_DATE|TIME_MINUTES);
            double open = rates[iBar].open;
            double high = rates[iBar].high;
            double low = rates[iBar].low;
            double close = rates[iBar].close;
            double volume = rates[iBar].tick_volume ;
            FileWrite(file, date, open, high, low, close, volume);
        }
        FileClose(file);
    }
}

// main function
void start()
{
    get_history();
    Alert("LOADING COMPLETE");
}
