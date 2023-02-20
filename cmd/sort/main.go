package main

import (
	"fmt"
	"github.com/Prucek/GNU_go_sort/internal/parse"
	"github.com/Prucek/GNU_go_sort/internal/sort"
	"os"
)

func main() {
	var lines []string
	arg := parse.ArgumentParsing()
	lines, err := parse.ScanLines(arg)
	if err != nil {
		fmt.Println(err)
		os.Exit(2)
	}
	sort.SortingAlgorithm(&lines, arg)

	for _, l := range lines {
		fmt.Println(l)
	}
}
