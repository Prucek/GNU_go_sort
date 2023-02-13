all:
	go build
	./main main.go

clean:
	rm main

test:
	go build
	./test_options.sh
	./test_diff_1.sh
	./test_diff_2.sh
	./test_diff_3.sh
	./test_multiple.sh
	cd gnu_sort && go test
	rm main