import Fluent
import Testing
import VaporTesting

@testable import MembersServer

private enum AdminLogsControllerTestHelper {
    static func sampleUser() -> User {
        User(firstName: "Regular", lastName: "User", email: "regular@test.com")
    }

    static func sampleAdminUser() -> User {
        User(firstName: "Admin", lastName: "User", email: "admin@test.com")
    }
}

@Suite("AdminLogsController Tests", .serialized)
struct AdminLogsControllerTests {
    // MARK: - Get Logs Tests

    @Test("Get Logs - Success (Admin)")
    func testGetLogsSuccess() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let adminLogService = AdminLogService(database: app.db)

            // Create Admin User
            let adminUser = try await userService.createUser(
                from: AdminLogsControllerTestHelper.sampleAdminUser())
            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminUser.$roles.create(adminRole, on: app.db)
            let headers = try await app.getTokenHeader(for: adminUser)

            // Create some logs
            try await adminLogService.addLog(for: adminUser.id!, "Log 1")
            try await adminLogService.addLog(for: adminUser.id!, "Log 2")

            try await app.testing().test(
                .GET,
                "/v1/admin-logs",
                headers: headers
            ) { res in
                #expect(res.status == .ok)
                let body = try res.content.decode(Page<AdminLogDTO>.self)
                #expect(body.items.count == 2)
                #expect(body.metadata.total == 2)
            }
        }
    }

    @Test("Get Logs - Non-Admin Returns Forbidden")
    func testGetLogsNonAdminForbidden() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)

            // Create Regular User
            let user = try await userService.createUser(
                from: AdminLogsControllerTestHelper.sampleUser())
            let headers: HTTPHeaders = try await app.getTokenHeader(for: user)

            try await app.testing().test(
                .GET,
                "/v1/admin-logs",
                headers: headers
            ) { res in
                #expect(res.status == .forbidden)
            }
        }
    }

    @Test("Get Logs - Unauthorized Without Token")
    func testGetLogsUnauthorized() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)

            // Create Regular User
            _ = try await userService.createUser(
                from: AdminLogsControllerTestHelper.sampleUser())

            try await app.testing().test(
                .GET,
                "/v1/admin-logs"
            ) { res in
                #expect(res.status == .unauthorized)
            }
        }
    }
}
