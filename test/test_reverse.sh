#!/usr/bin/env sh

# FROM SORT DOCUMENTATION
#*** WARNING ***
#The locale specified by the environment affects sort order.
#Set LC_ALL=C to get the traditional sort order that uses
#native byte values.

LC_ALL=C sort -r cmd/sort/main.go &> real.out
./cmd/sort/sort -r cmd/sort/main.go > test.out
diff real.out test.out > diff.out
./test/test.sh
