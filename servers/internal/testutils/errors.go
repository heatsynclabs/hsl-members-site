package testutils

type TestError string

func (e TestError) Error() string {
	return string(e)
}
