#!/usr/bin/env sh

RED='\033[0;31m'
GREEN='\033[0;32m'
Color_Off='\033[0m'  

# FROM SORT DOCUMENTATION
#*** WARNING ***
#The locale specified by the environment affects sort order.
#Set LC_ALL=C to get the traditional sort order that uses
#native byte values.

LC_ALL=C sort Makefile &> real.out
./main Makefile > my.out
diff real.out my.out > diff.out

if [`cat diff.out` -eq ""]; then
    printf "${GREEN} PASSED ${Color_Off}\n"
else
    cat diff.out
    printf "${RED} FAILED ${Color_Off}\n"
fi

rm my.out real.out diff.out