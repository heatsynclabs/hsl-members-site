import Fluent
import JWT
import Testing
import VaporTesting

@testable import MembersServer

@Suite("UserAuthenticator Tests With DB", .serialized)
struct UserAuthenticatorTests {

    @Test("Valid JWT creates new user and authenticates request")
    func testValidJwtCreatesUser() async throws {
        try await withApp { app in
            app.routes.grouped(UserAuthenticator())
                .get("test-auth") { req -> HTTPStatus in
                    // If we get here, middleware succeeded and user is logged in
                    _ = try req.auth.require(User.self)
                    return .ok
                }

            let newUserId = UUID()
            let payload = JwtUser(
                expiration: .init(value: .distantFuture),
                subject: .init(value: newUserId.uuidString),
                email: "test@example.com",
                metadata: .init(firstName: "Alice", lastName: "Dev")
            )

            let headers = try await app.getTokenHeader(for: payload)

            try await app.test(.GET, "test-auth", headers: headers) { res in
                #expect(res.status == .ok)
            }

            // Ensure the middleware actually created the user in the DB
            let userCount = try await User.query(on: app.db).count()
            let createdUser = try await User.find(newUserId, on: app.db)

            #expect(userCount == 1)
            #expect(createdUser?.email == "test@example.com")
        }
    }

    @Test("Expired JWT fails authentication")
    func testExpiredJwtFails() async throws {
        try await withApp { app in
            app.routes.grouped(UserAuthenticator())
                .get("test-auth") { _ in HTTPStatus.ok }

            let payload = JwtUser(
                expiration: .init(value: .distantPast),
                subject: .init(value: UUID().uuidString),
                email: "expired@example.com",
                metadata: nil
            )

            let headers = try await app.getTokenHeader(for: payload)

            try await app.test(.GET, "test-auth", headers: headers) { res in
                #expect(res.status == .unauthorized)
            }
        }
    }
}
