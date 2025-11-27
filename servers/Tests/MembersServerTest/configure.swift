import Fluent
import VaporTesting

@testable import MembersServer

func withApp(_ test: (Application) async throws -> Void) async throws {
    let app = try await Application.make(.testing)
    do {
        try await configure(app)

        // Add JWT token for testing controllers with auth
        await app.jwt.keys.add(hmac: "secret", digestAlgorithm: .sha256)

        try await test(app)
        try await app.autoRevert()
    } catch {
        try? await app.autoRevert()
        try await app.asyncShutdown()
        throw error
    }
    try await app.asyncShutdown()
}

extension Application {
    func getTokenHeader(for user: JwtUser) async throws -> HTTPHeaders {
        let token = try await self.jwt.keys.sign(user)
        return ["Authorization": "Bearer \(token)"]
    }

    func getTokenHeader(for user: User) async throws -> HTTPHeaders {
        let payload = JwtUser(
            expiration: .init(value: .distantFuture),
            subject: .init(value: user.id!.uuidString),
            email: user.email,
            metadata: .init(firstName: user.firstName, lastName: user.lastName)
        )
        return try await getTokenHeader(for: payload)
    }
}
