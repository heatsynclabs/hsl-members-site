import ArgumentParser

import enum Supabase.AnyJSON
import class Supabase.SupabaseClient

struct CreateUser: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "create-user",
        abstract: "Create a new user in Supabase Auth."
    )

    @Option(name: .shortAndLong, help: "The email of the user to create")
    var email: String

    @Option(name: .shortAndLong, help: "The password of the user to create")
    var password: String

    @Option(name: .shortAndLong, help: "The first name of the user")
    var firstName: String

    @Option(name: .shortAndLong, help: "The last name of the user")
    var lastName: String

    mutating func run() async throws {
        let client = SupabaseConfig.shared.client

        do {
            let user = try await client.auth.signUp(
                email: email,
                password: password,
                data: [
                    "first_name": .string(firstName),
                    "last_name": .string(lastName),
                ]
            )
            print("User created with ID: \(user.user.id)")
        } catch {
            print("Error creating user: \(error.localizedDescription)")
        }
    }
}
