#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "No arguments supplied. Usage ./runmorbo.sh <port>"
  else
	echo $1
	morbo -l "http://*:$1" dt_bot.pl -w Telegram/DynamicKeyboards.pm
fi
