package requestid

import (
	"net/http"

	"github.com/google/uuid"
	"github.com/heatsynclabs/hsl-members-site/internal/middleware/logger"
	"github.com/heatsynclabs/hsl-members-site/internal/middleware/sentrymw"
)

const (
	LogString = "request_id"
)

func RequestID(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		id := uuid.New()
		r.Header.Set("X-Request-ID", id.String())
		w.Header().Set("X-Request-ID", id.String())

		hub := sentrymw.GetHubFromContext(r.Context())
		hub.Scope().SetTag("request_id", id.String())

		logger.SetValueOnLogger(r.Context(), LogString, id.String())

		next.ServeHTTP(w, r)
	})
}
