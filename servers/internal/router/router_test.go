package router

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestNew(t *testing.T) {
	router := New()

	if router == nil {
		t.Fatal("New() returned nil")
	}

	if router.ServeMux == nil {
		t.Error("ServeMux is nil")
	}

	if router.chain == nil {
		t.Error("chain is nil")
	}

	if len(router.chain) != 0 {
		t.Errorf("expected empty chain, got length %d", len(router.chain))
	}
}

func TestUse(t *testing.T) {
	router := New()

	middleware1 := func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("X-Middleware-1", "true")
			next.ServeHTTP(w, r)
		})
	}

	middleware2 := func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("X-Middleware-2", "true")
			next.ServeHTTP(w, r)
		})
	}

	router.Use(middleware1)
	if len(router.chain) != 1 {
		t.Errorf("expected chain length 1, got %d", len(router.chain))
	}

	router.Use(middleware2)
	if len(router.chain) != 2 {
		t.Errorf("expected chain length 2, got %d", len(router.chain))
	}

}

func TestHTTPMethods(t *testing.T) {
	tests := []struct {
		name   string
		method string
		setup  func(*Router, string, http.Handler, ...middlewareFunc)
	}{
		{"GET", "GET", (*Router).Get},
		{"POST", "POST", (*Router).Post},
		{"PUT", "PUT", (*Router).Put},
		{"PATCH", "PATCH", (*Router).Patch},
		{"DELETE", "DELETE", (*Router).Delete},
		{"HEAD", "HEAD", (*Router).Head},
		{"OPTIONS", "OPTIONS", (*Router).Options},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			router := New()
			handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				w.WriteHeader(http.StatusOK)
				w.Write([]byte("success"))
			})

			tt.setup(router, "/test", handler)

			req := httptest.NewRequest(tt.method, "/test", nil)
			w := httptest.NewRecorder()

			router.ServeHTTP(w, req)

			if w.Code != http.StatusOK {
				t.Errorf("expected status %d, got %d", http.StatusOK, w.Code)
			}

			if body := w.Body.String(); body != "success" {
				t.Errorf("expected body 'success', got '%s'", body)
			}
		})
	}
}

func TestMiddlewareChaining(t *testing.T) {
	router := New()

	var order []string

	middleware1 := func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			order = append(order, "m1-before")
			next.ServeHTTP(w, r)
			order = append(order, "m1-after")
		})
	}

	middleware2 := func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			order = append(order, "m2-before")
			next.ServeHTTP(w, r)
			order = append(order, "m2-after")
		})
	}

	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		order = append(order, "handler")
		w.WriteHeader(http.StatusOK)
	})

	router.Use(middleware1)
	router.Use(middleware2)
	router.Get("/test", handler)

	req := httptest.NewRequest("GET", "/test", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	expected := []string{"m1-before", "m2-before", "handler", "m2-after", "m1-after"}
	if len(order) != len(expected) {
		t.Fatalf("expected %d calls, got %d", len(expected), len(order))
	}

	for i, exp := range expected {
		if order[i] != exp {
			t.Errorf("at position %d: expected %s, got %s", i, exp, order[i])
		}
	}
}

func TestRouteMiddleware(t *testing.T) {
	router := New()

	globalCalled := false
	routeCalled := false

	globalMiddleware := func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			globalCalled = true
			next.ServeHTTP(w, r)
		})
	}

	routeMiddleware := func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			routeCalled = true
			next.ServeHTTP(w, r)
		})
	}

	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	router.Use(globalMiddleware)
	router.Get("/test", handler, routeMiddleware)

	req := httptest.NewRequest("GET", "/test", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	if !globalCalled {
		t.Error("global middleware was not called")
	}

	if !routeCalled {
		t.Error("route middleware was not called")
	}
}

func TestGroup(t *testing.T) {
	router := New()

	globalCalled := false
	groupCalled := false

	globalMiddleware := func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			globalCalled = true
			next.ServeHTTP(w, r)
		})
	}

	groupMiddleware := func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			groupCalled = true
			next.ServeHTTP(w, r)
		})
	}

	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	router.Use(globalMiddleware)

	router.Group(func(r *Router) {
		r.Use(groupMiddleware)
		r.Get("/group", handler)
	})

	// Test that group middleware is applied
	req := httptest.NewRequest("GET", "/group", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	if !globalCalled {
		t.Error("global middleware was not called")
	}

	if !groupCalled {
		t.Error("group middleware was not called")
	}
}

func TestGroupIsolation(t *testing.T) {
	router := New()

	groupMiddlewareCalled := false

	groupMiddleware := func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			groupMiddlewareCalled = true
			next.ServeHTTP(w, r)
		})
	}

	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	router.Group(func(r *Router) {
		r.Use(groupMiddleware)
		r.Get("/group", handler)
	})

	// Add a route outside the group
	router.Get("/outside", handler)

	// Test that group middleware doesn't affect routes outside the group
	req := httptest.NewRequest("GET", "/outside", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	if groupMiddlewareCalled {
		t.Error("group middleware was called on route outside the group")
	}
}

func TestPathParameters(t *testing.T) {
	router := New()

	var capturedID string

	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		capturedID = r.PathValue("id")
		w.WriteHeader(http.StatusOK)
	})

	router.Get("/users/{id}", handler)

	req := httptest.NewRequest("GET", "/users/123", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	if capturedID != "123" {
		t.Errorf("expected path parameter '123', got '%s'", capturedID)
	}
}
