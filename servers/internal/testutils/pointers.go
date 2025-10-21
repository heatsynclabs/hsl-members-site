package testutils

func PointerOf[T any](v T) *T {
	return &v
}
