package parse

import (
	"github.com/Prucek/GNU_go_sort/internal/sort"
	"github.com/Prucek/GNU_go_sort/tools"
	"testing"
)

var ops = &Options{Files: []string{"read.go", "arguments.go", "read_test.go"}}
var naive = SortAlgorithm{FnAppend: tools.AppendWrapper, FnSort: sort.Lines}
var binary = SortAlgorithm{FnAppend: sort.BinarySearchAppend, FnSort: tools.EmptySortWrapper}

func BenchmarkScanLinesBinary(b *testing.B) {
	for i := 0; i < b.N; i++ {
		_, err := ScanLines(ops, binary)
		if err != nil {
			return
		}

	}
}

func BenchmarkScanLinesNaive(b *testing.B) {
	for i := 0; i < b.N; i++ {
		_, err := ScanLines(ops, naive)
		if err != nil {
			return
		}
	}
}
