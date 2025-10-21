package logger

import (
	"context"
	"log/slog"
	"net"
	"net/http"
	"slices"
	"time"
)

type responseWriter struct {
	http.ResponseWriter
	statusCode   int
	responseSize int
}

func (rw *responseWriter) WriteHeader(statusCode int) {
	rw.statusCode = statusCode
	rw.ResponseWriter.WriteHeader(statusCode)
}

func (rw *responseWriter) Write(b []byte) (int, error) {
	n, err := rw.ResponseWriter.Write(b)
	rw.responseSize += len(b)
	return n, err
}

type locator interface {
	GetLocation(ip string) (float64, float64, error)
}

// region Context
const contextKey = "logger"

type container struct {
	l *slog.Logger
}

func addLoggerToContext(r *http.Request, logger *slog.Logger) *http.Request {
	c := &container{l: logger}
	return r.WithContext(context.WithValue(r.Context(), contextKey, c))
}

func GetLoggerFromContext(ctx context.Context) *slog.Logger {
	c, ok := ctx.Value(contextKey).(*container)
	if !ok {
		panic("logger not found in context")
	}
	return c.l
}

func SetValueOnLogger(ctx context.Context, key string, value any) {
	c, ok := ctx.Value(contextKey).(*container)
	if !ok {
		panic("logger not found in context")
	}
	c.l = c.l.With(key, value)
}

// Logger returns a middleware that logs incoming HTTP requests.
// The middleware logs details such as duration, request ID, user information, URI, method,
// status code, IP address, user agent, request size, and response size.
//
// It also adds a logger to the context for use by downstream services
func Logger(logger *slog.Logger, loc locator, quietRoutes []string) func(handler http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			rc := addLoggerToContext(r, logger)

			if slices.Contains(quietRoutes, rc.URL.Path) {
				next.ServeHTTP(w, rc)
				return
			}

			currTime := time.Now()
			ww := &responseWriter{
				ResponseWriter: w,
				statusCode:     http.StatusTeapot,
				responseSize:   0,
			}

			logg := GetLoggerFromContext(rc.Context())

			defer func(start time.Time) {
				dur := time.Since(start)

				remoteIp := rc.RemoteAddr
				if host, _, err := net.SplitHostPort(remoteIp); err == nil {
					remoteIp = host
				}

				lat, long, _ := loc.GetLocation(remoteIp)

				logg.Info(
					"request",
					"duration_ms", dur.Milliseconds(),
					"uri", rc.RequestURI,
					"method", rc.Method,
					"status_code", ww.statusCode,
					"requester_ip", remoteIp,
					"lat", lat,
					"long", long,
					"user_agent", rc.UserAgent(),
					"request_size", rc.ContentLength,
					"response_size", ww.responseSize,
				)
			}(currTime)

			next.ServeHTTP(ww, rc)
		})
	}
}
