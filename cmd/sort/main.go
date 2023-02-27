package main

import (
	"fmt"
	"github.com/Prucek/GNU_go_sort/internal/parse"
	"github.com/Prucek/GNU_go_sort/internal/sort"
	"github.com/Prucek/GNU_go_sort/tools"
	"os"
)

func main() {
	var lines []string
	arg := parse.Arguments()

	//naive := parse.SortAlgorithm{FnAppend: tools.AppendWrapper, FnSort: sort.Lines}
	binary := parse.SortAlgorithm{FnAppend: sort.BinarySearchAppend, FnSort: tools.EmptySortWrapper}

	lines, err := parse.ScanLines(arg, binary)
	if err != nil {
		fmt.Println(err)
		os.Exit(2)
	}
	if arg.ReverseFlag {
		lines = tools.Reverse(lines)
	}
	for _, l := range lines {
		fmt.Println(l)
	}
}
