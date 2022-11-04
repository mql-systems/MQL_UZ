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
void get_history()
{
    int iBar, iPeriod, rates_count, historyBarCnt, file;
    string symbol_name;
    
    for (int i = 0; i <= 8 ; i++)
    {
        iPeriod = minutes[i];
        symbol_name = Symbol() + IntegerToString(iPeriod);
        
        //--- loading history
        MqlRates rates[];
        for (int r = 1; r < 4; r++)
        {
            rates_count = CopyRates(Symbol(), iPeriod, start_date, end_date, rates);
            if (rates_count > 0)
            {
               historyBarCnt = Bars(_Symbol, iPeriod, start_date, end_date);
               if (historyBarCnt == rates_count)
                  break;
            }
            rates_count = 0;
            Sleep(r * 100);
        }

        if (rates_count < 1)
        {
            Alert("ERROR: The " + symbol_name + " pair quote is not fully loaded");
            return;
        }
        
        //--- conversion to csv
        file = FileOpen(symbol_name + ".csv", FILE_CSV | FILE_WRITE, ',');
        if (file != INVALID_HANDLE)
        {
            FileWrite(file, "Time", "Open", "High", "Low", "Close", "Volume");
            for (iBar = 0; iBar < bar ; iBar++)
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
    
    return;
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
