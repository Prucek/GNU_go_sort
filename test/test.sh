#!/usr/bin/env sh
set -o errexit
set -o nounset
set -o pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
Color_Off='\033[0m'

diff real.out test.out > diff.out

if [`cat diff.out` -eq ""]; then
    printf "${GREEN} PASSED ${Color_Off}\n"
    rm test.out real.out diff.out
else
    cat diff.out
    printf "${RED} FAILED ${Color_Off}\n"
fi