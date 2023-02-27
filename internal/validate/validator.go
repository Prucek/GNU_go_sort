package validate

import (
	"errors"
	"fmt"
	"os"
)

func IsFile(filename string) (err error) {
	var info os.FileInfo
	info, err = os.Stat(filename)
	if os.IsNotExist(err) {
		err = errors.New(fmt.Sprintf("sort: cannot read: %s: No such file or directory", filename))
	} else if info.IsDir() {
		err = errors.New(fmt.Sprintf("sort: read failed: %s: Is a directory", filename))
	}
	return
}
