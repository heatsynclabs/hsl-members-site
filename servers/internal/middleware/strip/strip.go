package strip

import (
	"net/http"
	"strings"
)

// Strip returns a http.Handler that serves HTTP requests by removing up to the given prefix from the request URL's Path.
func Strip(handler http.Handler, prefix string) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		originalPath := r.URL.Path
		if idx := strings.Index(originalPath, prefix); idx != -1 {
			r.URL.Path = originalPath[idx:]
		}

		handler.ServeHTTP(w, r)
	})
}
