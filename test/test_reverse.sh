#!/usr/bin/env sh

# FROM SORT DOCUMENTATION
#*** WARNING ***
#The locale specified by the environment affects sort order.
#Set LC_ALL=C to get the traditional sort order that uses
#native byte values.

FILE=cmd/sort/main.go REVERSE=true ./test/test.sh
