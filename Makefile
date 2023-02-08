all:
	go build GNU_sort.go
	./GNU_sort GNU_sort.go

clean:
	rm GNU_sort