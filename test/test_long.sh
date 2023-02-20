#!/usr/bin/env sh
#set -o errexit
set -o nounset
set -o pipefail

# FROM SORT DOCUMENTATION
#*** WARNING ***
#The locale specified by the environment affects sort order.
#Set LC_ALL=C to get the traditional sort order that uses
#native byte values.

wget wget https://en.wikipedia.org/wiki/Chess -qO long
LC_ALL=C sort long &> real.out
./sort long > test.out
./test/test.sh
rm long