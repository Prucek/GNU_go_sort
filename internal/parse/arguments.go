package parse

import (
	"errors"
	"flag"
	"io"
	"os"
	"strings"

	"github.com/Prucek/GNU_go_sort/internal/validate"
)

type Options struct {
	ReverseFlag bool
	Files       []string
	fromStdin   bool
}

func optionFlags(ops *Options) {
	flag.BoolVar(&(ops.ReverseFlag), "reverse", false, "reverse the result of comparisons")
	flag.BoolVar(&(ops.ReverseFlag), "r", false, "reverse the result of comparisons")
	flag.Parse()
}

func Arguments() *Options {
	ops := Options{}
	optionFlags(&ops)
	ops.Files = flag.Args()
	if len(ops.Files) == 0 || (len(ops.Files) == 1 && ops.Files[0] == "-") {
		ops.fromStdin = true
	}
	return &ops
}

func (o *Options) OpenFiles() ([]io.ReadCloser, error) {
	if o.fromStdin {
		return []io.ReadCloser{io.NopCloser(os.Stdin)}, nil
	}
	errMsgs := make([]string, 0, len(o.Files))
	files := make([]io.ReadCloser, 0, len(o.Files))
	for _, filename := range o.Files {
		if err := validate.IsFile(filename); err != nil {
			errMsgs = append(errMsgs, err.Error())
			continue
		}
		f, err := os.Open(filename)
		if err != nil {
			errMsgs = append(errMsgs, err.Error())
			continue
		}
		files = append(files, f)
	}
	var err error
	if len(errMsgs) > 0 {
		err = errors.New(strings.Join(errMsgs, ", "))
	}
	return files, err
}
