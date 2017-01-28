#!/bin/bash 
 COUNTER=0
while [  $COUNTER -lt 5 ]; do
kill $(pgrep telegram-cli)
python3 anticrash.py start
sleep 300
#let COUNTER=COUNTER+1 
done
