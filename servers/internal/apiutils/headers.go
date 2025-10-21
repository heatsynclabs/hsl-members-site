package apiutils

import (
	"fmt"
	"net/http"
	"strconv"
	"time"
)

func formatDuration(d time.Duration) string {
	return fmt.Sprintf("%.0f", d.Seconds())
}

func GetCachingHeaders(maxAge time.Duration, staleWhileRevalidate time.Duration) http.Header {
	headers := make(http.Header)

	// Set Cache-Control header
	m := fmt.Sprintf("max-age=%s", formatDuration(maxAge))
	s := fmt.Sprintf("stale-while-revalidate=%s", formatDuration(staleWhileRevalidate))
	headers.Set("Cache-Control", "private")
	headers.Set("Cache-Control", m)
	headers.Set("Cache-Control", s)

	// Expires header for backwards compatability
	expires := time.Now().Add(maxAge).Format(http.TimeFormat)
	headers.Set("Expires", expires)

	return headers
}

const (
	expectedVersionHeader = "X-Expected-Version"
)

// CheckExpectedVersion retrieves the "X-Expected-Version" header, validates it, and returns it as an integer or an error.
// Returns ErrVersionHeaderMissing if the header is not present or ErrVersionNotInt if the header value is not an integer.
func CheckExpectedVersion(r *http.Request) (int, error) {
	expectedVersionH := r.Header.Get(expectedVersionHeader)
	if expectedVersionH == "" {
		return 0, ErrVersionHeaderMissing
	}

	eVersion, err := strconv.Atoi(expectedVersionH)
	if err != nil {
		return 0, ErrVersionNotInt
	}

	return eVersion, nil
}
