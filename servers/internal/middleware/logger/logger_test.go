package logger

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"testing"
)

type mockLoc struct {
	getLocFunc func(ip string) (float64, float64, error)
}

func (m *mockLoc) GetLocation(ip string) (float64, float64, error) {
	if m.getLocFunc == nil {
		return 0, 0, nil
	}
	return m.getLocFunc(ip)
}

func TestLoggerMiddleware(t *testing.T) {
	// Create a buffer to capture log output
	var buf bytes.Buffer
	logger := slog.New(slog.NewJSONHandler(&buf, nil))

	logMiddleware := Logger(logger, &mockLoc{}, []string{})

	// Create a new handler to test the middleware
	testHandler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("Hello, World!"))
	})

	// Wrap the handler with the middleware
	handler := logMiddleware(testHandler)

	// Create a new HTTP request
	testRequestId := "test-request-id"
	req := httptest.NewRequest("GET", "http://example.com/foo", nil)
	req.Header.Set("X-Request-Id", testRequestId)
	req = req.WithContext(context.WithValue(req.Context(), "user", "test-user"))

	// Create a ResponseRecorder to capture the response
	rr := httptest.NewRecorder()

	// Call the handler with the ResponseRecorder and request
	handler.ServeHTTP(rr, req)

	// Check the status code
	if rr.Code != http.StatusOK {
		t.Errorf("Expected status code %d, got %d", http.StatusOK, rr.Code)
	}

	// Check the response body
	expectedBody := "Hello, World!"
	body, _ := io.ReadAll(rr.Body)
	if string(body) != expectedBody {
		t.Errorf("Expected body %q, got %q", expectedBody, string(body))
	}

	// Check if log output contains expected content
	logOutput := make(map[string]any)
	err := json.Unmarshal(buf.Bytes(), &logOutput)
	if err != nil {
		t.Fatalf("Failed to unmarshal log output: %v", err)
	}
}
