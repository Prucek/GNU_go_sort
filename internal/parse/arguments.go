package parse

import (
	"flag"
)

type Options struct {
	ReverseFlag bool
	Files       []string
}

func optionFlags(ops *Options) {
	flag.BoolVar(&(ops.ReverseFlag), "reverse", false, "reverse the result of comparisons")
	flag.BoolVar(&(ops.ReverseFlag), "r", false, "reverse the result of comparisons")
	flag.Parse()
}

func ArgumentParsing() *Options {
	ops := Options{}
	optionFlags(&ops)
	ops.Files = flag.Args()
	if len(ops.Files) == 0 {
		READ_STDIN = true
	} else if len(ops.Files) > 0 {
		READ_STDIN = false
	}
	return &ops
}
