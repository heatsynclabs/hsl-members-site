import Fluent
import Testing
import VaporTesting

@testable import MembersServer

@Suite("InstructorService Tests with DB", .serialized)
struct InstructorServiceTests {
    private static func sampleStation(name: String = "Test Station") -> Station {
        Station(name: name)
    }

    private static func sampleUser(
        firstName: String = "Test",
        lastName: String = "User",
        email: String = "test@example.com"
    ) -> User {
        User(
            firstName: firstName,
            lastName: lastName,
            email: email
        )
    }

    private func createAdminUser(on db: any Database) async throws -> User {
        let user = User(firstName: "Admin", lastName: "User", email: "admin@test.com")
        try await user.save(on: db)
        return user
    }

    @Test("Test Add Instructor")
    func testAddInstructor() async throws {
        try await withApp { app in
            let adminLogService = AdminLogService(database: app.db)
            let instructorService = InstructorService(database: app.db, adminLogger: adminLogService)
            let adminUser = try await createAdminUser(on: app.db)

            let station = Self.sampleStation()
            try await station.save(on: app.db)
            guard let stationId = station.id else {
                #expect(Bool(false), "Station ID was nil")
                return
            }

            let user = Self.sampleUser()
            try await user.save(on: app.db)
            guard let userId = user.id else {
                #expect(Bool(false), "User ID was nil")
                return
            }

            let instructorDTO = try await instructorService.addInstructor(asUser: adminUser.requireID(), to: stationId, userId: userId)

            #expect(instructorDTO.firstName == user.firstName)
            #expect(instructorDTO.lastName == user.lastName)
            #expect(instructorDTO.email == user.email)

            // Verify persistence
            let savedInstructor = try await Instructor.find(instructorDTO.userId, on: app.db)
            #expect(savedInstructor != nil)
            #expect(savedInstructor?.$user.id == userId)
            #expect(savedInstructor?.$station.id == stationId)

            // Check Admin Log
            let logs = try await AdminLog.query(on: app.db).with(\.$user).all()
            #expect(logs.count == 1)
            #expect(logs.first?.user.id == adminUser.id)
            #expect(logs.first?.log.contains("Added user \(userId) as an instructor") ?? false)
        }
    }

    @Test("Test Add Instructor - User Not Found")
    func testAddInstructorUserNotFound() async throws {
        try await withApp { app in
            let adminLogService = AdminLogService(database: app.db)
            let instructorService = InstructorService(database: app.db, adminLogger: adminLogService)
            let adminUser = try await createAdminUser(on: app.db)

            let station = Self.sampleStation()
            try await station.save(on: app.db)
            guard let stationId = station.id else {
                #expect(Bool(false), "Station ID was nil")
                return
            }

            await #expect(throws: UserError.userNotFound) {
                _ = try await instructorService.addInstructor(asUser: adminUser.requireID(), to: stationId, userId: UUID())
            }
        }
    }

    @Test("Test Add Instructor - Station Not Found")
    func testAddInstructorStationNotFound() async throws {
        try await withApp { app in
            let adminLogService = AdminLogService(database: app.db)
            let instructorService = InstructorService(database: app.db, adminLogger: adminLogService)
            let adminUser = try await createAdminUser(on: app.db)

            let user = Self.sampleUser()
            try await user.save(on: app.db)
            guard let userId = user.id else {
                #expect(Bool(false), "User ID was nil")
                return
            }

            await #expect(throws: StationError.stationNotFound) {
                _ = try await instructorService.addInstructor(asUser: adminUser.requireID(), to: UUID(), userId: userId)
            }
        }
    }

    @Test("Test Add Duplicate Instructor Throws Error")
    func testAddDuplicateInstructor() async throws {
        try await withApp { app in
            let adminLogService = AdminLogService(database: app.db)
            let instructorService = InstructorService(database: app.db, adminLogger: adminLogService)
            let adminUser = try await createAdminUser(on: app.db)

            let station = Self.sampleStation()
            try await station.save(on: app.db)
            guard let stationId = station.id else {
                #expect(Bool(false), "Station ID was nil")
                return
            }

            let user = Self.sampleUser()
            try await user.save(on: app.db)
            guard let userId = user.id else {
                #expect(Bool(false), "User ID was nil")
                return
            }

            _ = try await instructorService.addInstructor(asUser: adminUser.requireID(), to: stationId, userId: userId)

            await #expect(throws: InstructorError.uniqueViolation(field: .instructor)) {
                _ = try await instructorService.addInstructor(asUser: adminUser.requireID(), to: stationId, userId: userId)
            }
        }
    }

    @Test("Test Delete Instructor")
    func testDeleteInstructor() async throws {
        try await withApp { app in
            let adminLogService = AdminLogService(database: app.db)
            let instructorService = InstructorService(database: app.db, adminLogger: adminLogService)
            let adminUser = try await createAdminUser(on: app.db)

            let station = Self.sampleStation()
            try await station.save(on: app.db)
            guard let stationId = station.id else {
                #expect(Bool(false), "Station ID was nil")
                return
            }

            let user = Self.sampleUser()
            try await user.save(on: app.db)
            guard let userId = user.id else {
                #expect(Bool(false), "User ID was nil")
                return
            }

            let instructor = Instructor(userID: userId, stationID: stationId)
            try await instructor.save(on: app.db)

            try await instructorService.deleteInstructor(asUser: adminUser.requireID(), userId: userId, stationId: stationId)

            let found = try await Instructor.find(instructor.id, on: app.db)
            #expect(found == nil)

            // Check Admin Log
            let logs = try await AdminLog.query(on: app.db).with(\.$user).all()
            #expect(logs.count == 1)
            #expect(logs.first?.user.id == adminUser.id)
            #expect(logs.first?.log.contains("Delete user \(userId) as an instructor") ?? false)
        }
    }

    @Test("Test Deleting Already Existing User Does Not Throw")
    func testDeleteNotExistantInstructor() async throws {
        try await withApp { app in
            let adminLogService = AdminLogService(database: app.db)
            let instructorService = InstructorService(database: app.db, adminLogger: adminLogService)
            let adminUser = try await createAdminUser(on: app.db)

            let station = Self.sampleStation()
            try await station.save(on: app.db)
            guard station.id != nil else {
                #expect(Bool(false), "Station ID was nil")
                return
            }

            let user = Self.sampleUser()
            try await user.save(on: app.db)
            guard user.id != nil else {
                #expect(Bool(false), "User ID was nil")
                return
            }

            try await instructorService.deleteInstructor(asUser: adminUser.requireID(), userId: UUID(), stationId: UUID())
        }
    }
}
