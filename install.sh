#!/bin/bash

# identify the terminal folder
echo -n "Enter the path to the MetaTrader 4(or 5): "
read mtPath
mtPath=` echo $mtPath | sed 's/\/*$//g' `
echo "----------------------------------------"

if [ -d $mtPath"/MQL4" ]; then
	mtPath+="/MQL4"
elif [[ -d $mtPath"/MQL5" ]]; then
	mtPath+="/MQL5"
else
	echo "Error: Wrong path!"
	exit
fi

# create links
for mqlDir in $(ls $PWD"/MQL")
do
	ln -s "$PWD/MQL/$mqlDir/Mql_uz" "$mtPath/$mqlDir/Mql_uz"
	echo "$mqlDir: Success!"
done
