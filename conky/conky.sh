#!/bin/sh
sleep 5
#conky -q -c ~/Conky/conkyrc1 & # This one is the sidebar with the clock and stats
#sleep 2
#conky -q -c ~/Conky/conkyrc2 & # This one has the python scripts in it
#sleep 2
conky -q -c ~/Conky/conkyrc3 & # This one is the Housewares list
sleep 2 
conky -q -c ~/Conky/conkyrc4 & exit # This one is the Grocery list
exit 0