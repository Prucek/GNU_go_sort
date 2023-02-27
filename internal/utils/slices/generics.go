package slices

import "io"

// TODO: consider using generics (if possible) to rewrite this
func ToReaders(xs []io.ReadCloser) []io.Reader {
	ys := make([]io.Reader, 0, len(xs))
	for _, x := range xs {
		ys = append(ys, x)
	}
	return ys
}
