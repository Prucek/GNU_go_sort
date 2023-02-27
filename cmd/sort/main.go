package main

import (
	"fmt"
	"os"

	"github.com/Prucek/GNU_go_sort/internal/parse"
	"github.com/Prucek/GNU_go_sort/internal/sort"
	"github.com/Prucek/GNU_go_sort/internal/utils/slices"
	"github.com/Prucek/GNU_go_sort/tools"
)

func main() {
	var lines []string
	arg := parse.Arguments()

	//naive := parse.SortAlgorithm{FnAppend: tools.AppendWrapper, FnSort: sort.Lines}
	binary := parse.SortAlgorithm{FnAppend: sort.BinarySearchAppend, FnSort: tools.EmptySortWrapper}

	files, err := arg.OpenFiles()
	defer func() {
		for _, f := range files {
			if err := f.Close(); err != nil {
				fmt.Println(err)
				os.Exit(2)
			}
		}
	}()
	if err != nil {
		fmt.Println(err)
		os.Exit(2)
	}
	lines, err = parse.ScanLines(slices.ToReaders(files), binary)
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
