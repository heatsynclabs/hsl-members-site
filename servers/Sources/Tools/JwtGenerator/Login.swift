import ArgumentParser

import struct Foundation.URL
import class Supabase.SupabaseClient

struct Login: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "login",
        abstract: "Login to Supabase and print the JWT access token."
    )

    @Option(name: .shortAndLong, help: "The email of the user to login")
    var email: String

    @Option(name: .shortAndLong, help: "The password of the user to login")
    var password: String

    mutating func run() async throws {
        let client = SupabaseConfig.shared.client
        do {
            let session = try await client.auth.signIn(email: email, password: password)
            print("\(session.accessToken)")
        } catch {
            print("Error signing in: \(error.localizedDescription)")
        }
    }
}
