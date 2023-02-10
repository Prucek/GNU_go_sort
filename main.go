package main

import (
	"fmt"
	"main/gnu_sort"
)

func main() {

	var lines []string
	lines = gnu_sort.ScanLines()
	gnu_sort.SortingAlgorithm(&lines)

	for _, l := range lines {
		fmt.Println(l)
	}
}
