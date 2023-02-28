package parse

import (
	"io"
	"testing"

	"github.com/Prucek/GNU_go_sort/internal/sort"
	"github.com/Prucek/GNU_go_sort/internal/utils/slices"
	"github.com/Prucek/GNU_go_sort/tools"
)

var ops = &Options{Files: []string{"read.go", "arguments.go", "read_test.go"}}
var naive = SortAlgorithm{FnAppend: tools.AppendWrapper, FnSort: sort.Lines}
var binary = SortAlgorithm{FnAppend: sort.BinarySearchAppend, FnSort: tools.EmptySortWrapper}

func BenchmarkScanLinesBinary(b *testing.B) {
	files, err := ops.OpenFiles()
	if err != nil {
		b.Fatal(err)
	}
	defer closeOrFail(b, files)
	for i := 0; i < b.N; i++ {
		_, err := ScanLines(slices.ToReaders(files), binary)
		if err != nil {
			return
		}

	}
}

func BenchmarkScanLinesNaive(b *testing.B) {
	files, err := ops.OpenFiles()
	if err != nil {
		b.Fatal(err)
	}
	defer closeOrFail(b, files)
	for i := 0; i < b.N; i++ {
		_, err := ScanLines(slices.ToReaders(files), naive)
		if err != nil {
			return
		}
	}
}

func closeOrFail(b *testing.B, files []io.ReadCloser) {
	for _, f := range files {
		if err := f.Close(); err != nil {
			b.Fatal(err)
		}
	}
}
