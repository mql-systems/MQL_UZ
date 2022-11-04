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

extern datetime start_date = __DATETIME__;
extern datetime end_date = __DATETIME__;


// list of timeframes
int minutes[9] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

// a function that downloads the history of quotations to a csv file
int get_history()
{
    for (int i = 0; i <= 8 ; i++)
    {
        int iPeriod = minutes[i];
        int rates_count = 0;
        string symbol_name = Symbol() + IntegerToString(iPeriod);
        MqlRates rates[];
        for (int r = 1; r < 4; r++)
        {
            rates_count = CopyRates(Symbol(), iPeriod, start_date, end_date, rates);
            if (rates_count > 0)
            {
               int barCnt = Bars(_Symbol, iPeriod, start_date, end_date);
               if (barCnt == rates_count)
                  break;
               else Sleep(r * 100);
            }
            if (rates_count < 1)
            {
                Alert("ERROR: The " + symbol_name + " pair quote is not fully loaded");
                return(0);
            }
            rates_count = 0;
        }
        int bar = ArrayRange(rates, 0);
        int file = FileOpen(symbol_name + ".csv", FILE_CSV | FILE_WRITE, ',');
        if (file != INVALID_HANDLE)
        {
            FileWrite(file, "Time", "Open", "High", "Low", "Close", "Volume");
            for (int iBar = 0; iBar < bar ; iBar++)
            {
                FileWrite(
                    file,
                    TimeToString(rates[iBar].time, TIME_DATE|TIME_MINUTES),
                    rates[iBar].open,
                    rates[iBar].high,
                    rates[iBar].low,
                    rates[iBar].close,
                    rates[iBar].tick_volume
                );
            }
            FileClose(file);
        }
        else
        {
            Alert("ERROR: Invalid open file");
        }
    }
    return(1);
}

// main function
void start()
{
    if (start_date < end_date)
    {
        get_history();
        Alert("LOADING COMPLETE");
    }
    else
    {
        Alert("ERROR: The timing is wrong");
    }
}
