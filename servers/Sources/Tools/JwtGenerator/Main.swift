import Supabase

import struct Foundation.URL

@main
enum Main {
    static func main() async throws {
        let client = SupabaseClient(
            supabaseURL: URL(string: "https://fcctfigwgmjcpkgoorxr.supabase.co")!,
            supabaseKey:
                "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZjY3RmaWd3Z21qY3BrZ29vcnhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1NzI0OTMsImV4cCI6MjA3ODE0ODQ5M30._tLpbbANTeFRrZzl2qCVrDDeSYW4kC5a1_u57dqTCbE"
        )

        do {
            let session = try await client.auth.signIn(email: "test@test.com", password: "test")
            print("\(session.accessToken)")
        } catch {
            print("Error signing in: \(error.localizedDescription)")
        }
    }
}
