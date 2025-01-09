#!/usr/bin/env sh
RED='\033[0;31m'
GREEN='\033[0;32m'
Color_Off='\033[0m'

if [ $REVERSE ]; then
    LC_ALL=C sort -r $FILE 2>&1 | diff - <(./sort -r $FILE 2>&1)
else
    LC_ALL=C sort $FILE 2>&1 | diff - <(./sort $FILE 2>&1)
fi

if [ $? -eq "0" ]; then
    printf "${GREEN} PASSED ${Color_Off}\n"
else
    printf "${RED} FAILED ${Color_Off}\n"
fi