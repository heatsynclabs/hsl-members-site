package sentrymw

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"
	"time"

	"github.com/getsentry/sentry-go"
)

const (
	SentryKey      = "sentry"
	sentryNotFound = "sentry not found in context"
	requestIdKey   = "X-Request-Id"

	sentryFlush = time.Second * 2
)

// GetHubFromContext returns the sentry hub stored within the request context.
//
// Panics if the context is not found.
func GetHubFromContext(ctx context.Context) *sentry.Hub {
	hub, ok := ctx.Value(SentryKey).(*sentry.Hub)
	if !ok {
		panic(sentryNotFound)
	}
	return hub
}

func setHubContext(r *http.Request, hub *sentry.Hub) *http.Request {
	ctx := context.WithValue(r.Context(), SentryKey, hub)
	return r.WithContext(ctx)
}

// New initializes Sentry, launches a goroutine to flush sentry upon context cancellation,
// and returns a middleware that recovers from panics and adds a sentry hub to each request
func New(ctx context.Context, dsn, env string, logger *slog.Logger) (func(http.Handler) http.Handler, error) {
	if err := sentry.Init(sentry.ClientOptions{
		Dsn:         dsn,
		Environment: env,
	}); err != nil {
		return nil, err
	}

	go func(ctx context.Context) {
		select {
		case <-ctx.Done():
			sentry.Flush(sentryFlush)
		}
	}(ctx)

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			defer func() {
				if err := recover(); err != nil {
					requestId := r.Header.Get(requestIdKey)
					logger.Error("panic encountered", "request_id", requestId, "error", err)

					hub := GetHubFromContext(r.Context())
					switch v := err.(type) {
					case error:
						hub.CaptureException(v)
					default:
						hub.CaptureException(fmt.Errorf("%s", v))
					}

					w.Header().Set("Connection", "close")
					w.WriteHeader(http.StatusInternalServerError)
				}
			}()

			hub := sentry.CurrentHub().Clone()
			r = setHubContext(r, hub)
			next.ServeHTTP(w, r)
		})
	}, nil
}
