package strip

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

type mockHandler struct {
	path string
}

func (m *mockHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	m.path = r.URL.Path
}

func TestStripPrefix(t *testing.T) {
	tests := []struct {
		name         string
		inputPath    string
		prefix       string
		expectedPath string
	}{
		{
			name:         "prefix at start",
			inputPath:    "/api/v1/users",
			prefix:       "/api",
			expectedPath: "/api/v1/users",
		},
		{
			name:         "prefix in middle",
			inputPath:    "/api/v1/users",
			prefix:       "/v1",
			expectedPath: "/v1/users",
		},
		{
			name:         "prefix at end",
			inputPath:    "/api/v1/users",
			prefix:       "/users",
			expectedPath: "/users",
		},
		{
			name:         "empty prefix",
			inputPath:    "/api/v1/users",
			prefix:       "",
			expectedPath: "/api/v1/users",
		},
		{
			name:         "prefix not found",
			inputPath:    "/api/v1/users",
			prefix:       "/foo",
			expectedPath: "/api/v1/users",
		},
	}

	for _, testCase := range tests {
		tt := testCase
		t.Run(tt.name, func(t *testing.T) {
			mock := &mockHandler{}

			middleware := Strip(mock, tt.prefix)

			req := httptest.NewRequest(http.MethodGet, tt.inputPath, nil)
			rr := httptest.NewRecorder()

			middleware.ServeHTTP(rr, req)

			if mock.path != tt.expectedPath {
				t.Errorf("expected path %s, got %s", tt.expectedPath, mock.path)
			}
		})
	}
}

func TestStripPrefix_NilHandler(t *testing.T) {
	defer func() {
		if r := recover(); r == nil {
			t.Errorf("expected panic")
		}
	}()

	middleware := Strip(nil, "/api")

	req := httptest.NewRequest(http.MethodGet, "/api/v1/users", nil)
	rr := httptest.NewRecorder()
	middleware.ServeHTTP(rr, req)
}

func TestStripPrefix_WriteThrough(t *testing.T) {
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})
	middleware := Strip(handler, "")

	req := httptest.NewRequest(http.MethodGet, "/api/v1/users", nil)
	rr := httptest.NewRecorder()
	middleware.ServeHTTP(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("expected status code %d, got %d", http.StatusOK, rr.Code)
	}
}
