.PHONY: clean

PATH2MAIN := "./cmd/..."

all: build

clean:
	rm -f sort *.out

build:	
	go build $(PATH2MAIN)

tests: build
	./test/test_options.sh
	./test/test_diff_1.sh
	./test/test_diff_2.sh
	./test/test_diff_3.sh
	./test/test_long.sh
	./test/test_multiple.sh
	./test/test_reverse.sh
	cd internal/sort && go test
	rm -f sort