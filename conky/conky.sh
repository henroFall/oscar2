#!/bin/sh
sleep 5
conky -q -c ~/Conky/conkyrc1 &
sleep 2
#conky -q -c ~/Conky/conkyrc2 & # This one had the python scripts in it
#sleep 2
conky -q -c ~/Conky/conkyrc3 &
sleep 2 
conky -q -c ~/Conky/conkyrc4 & exit
exit 0