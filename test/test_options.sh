#!/usr/bin/env sh

RED='\033[0;31m'
GREEN='\033[0;32m'
Color_Off='\033[0m' 

#not a file
LC_ALL=C  sort a &> real.out
./main a > test.out
diff real.out test.out > diff.out

if [`cat diff.out` -eq ""]; then
    printf "${GREEN} PASSED ${Color_Off}\n"
else
    cat diff.out
    printf "${RED} FAILED ${Color_Off}\n"
fi

#directory
LC_ALL=C  sort . &> real.out
./main . > test.out
diff real.out test.out > diff.out

if [`cat diff.out` -eq ""]; then
    printf "${GREEN} PASSED ${Color_Off}\n"
    rm test.out real.out diff.out
else
    cat diff.out
    printf "${RED} FAILED ${Color_Off}\n"
fi

