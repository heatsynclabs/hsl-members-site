// swiftlint:disable line_length
import struct Foundation.URL
import class Supabase.SupabaseClient

struct SupabaseConfig {
    static let shared = SupabaseConfig()

    let client: SupabaseClient

    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://fcctfigwgmjcpkgoorxr.supabase.co")!,
            // Public key, so this is safe to commit
            supabaseKey:
                "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZjY3RmaWd3Z21qY3BrZ29vcnhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1NzI0OTMsImV4cCI6MjA3ODE0ODQ5M30._tLpbbANTeFRrZzl2qCVrDDeSYW4kC5a1_u57dqTCbE",
            options: .init()
        )
    }
}
