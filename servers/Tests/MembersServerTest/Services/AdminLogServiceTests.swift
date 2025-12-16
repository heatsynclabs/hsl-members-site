import Fluent
import Testing
import VaporTesting

@testable import MembersServer

@Suite("AdminLogService Tests with DB", .serialized)
struct AdminLogServiceTests {
    private static func sampleUser(
        firstName: String = "Test",
        lastName: String = "User",
        email: String = "test@example.com"
    ) -> User {
        User(firstName: firstName, lastName: lastName, email: email)
    }

    @Test("Test Add Log")
    func testAddLog() async throws {
        try await withApp { app in
            let adminLogService = AdminLogService(database: app.db)

            let user = Self.sampleUser()
            try await user.save(on: app.db)
            guard let userId = user.id else {
                #expect(Bool(false), "User ID was nil")
                return
            }

            let logMessage = "Test log entry"
            try await adminLogService.addLog(for: userId, logMessage)

            let logs = try await AdminLog.query(on: app.db).all()
            #expect(logs.count == 1)
            #expect(logs.first?.log == logMessage)
            #expect(logs.first?.$user.id == userId)
        }
    }

    @Test("Test Get Logs")
    func testGetLogs() async throws {
        try await withApp { app in
            let adminLogService = AdminLogService(database: app.db)

            let user = Self.sampleUser()
            try await user.save(on: app.db)
            guard let userId = user.id else {
                #expect(Bool(false), "User ID was nil")
                return
            }

            let logMessage1 = "Log 1"
            let logMessage2 = "Log 2"

            try await adminLogService.addLog(for: userId, logMessage1)
            try await adminLogService.addLog(for: userId, logMessage2)

            let pageRequest = PageRequest(page: 1, per: 10)
            let logsPage = try await adminLogService.getLogs(page: pageRequest)

            #expect(logsPage.metadata.total == 2)
            #expect(logsPage.items.count == 2)

            let log1 = logsPage.items.first { $0.log == logMessage1 }
            let log2 = logsPage.items.first { $0.log == logMessage2 }

            #expect(log1 != nil)
            #expect(log2 != nil)

            #expect(log1?.user.id == userId)
            #expect(log2?.user.id == userId)
        }
    }
}
