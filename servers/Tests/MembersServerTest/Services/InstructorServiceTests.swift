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

    @Test("Test Add Instructor")
    func testAddInstructor() async throws {
        try await withApp { app in
            let instructorService = InstructorService(database: app.db)

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

            let instructorDTO = try await instructorService.addInstructor(to: stationId, userId: userId)

            #expect(instructorDTO.firstName == user.firstName)
            #expect(instructorDTO.lastName == user.lastName)
            #expect(instructorDTO.email == user.email)

            // Verify persistence
            let savedInstructor = try await Instructor.find(instructorDTO.userId, on: app.db)
            #expect(savedInstructor != nil)
            #expect(savedInstructor?.$user.id == userId)
            #expect(savedInstructor?.$station.id == stationId)
        }
    }

    @Test("Test Add Instructor - User Not Found")
    func testAddInstructorUserNotFound() async throws {
        try await withApp { app in
            let instructorService = InstructorService(database: app.db)

            let station = Self.sampleStation()
            try await station.save(on: app.db)
            guard let stationId = station.id else {
                #expect(Bool(false), "Station ID was nil")
                return
            }

            await #expect(throws: UserError.userNotFound) {
                _ = try await instructorService.addInstructor(to: stationId, userId: UUID())
            }
        }
    }

    @Test("Test Add Instructor - Station Not Found")
    func testAddInstructorStationNotFound() async throws {
        try await withApp { app in
            let instructorService = InstructorService(database: app.db)

            let user = Self.sampleUser()
            try await user.save(on: app.db)
            guard let userId = user.id else {
                #expect(Bool(false), "User ID was nil")
                return
            }

            await #expect(throws: StationError.stationNotFound) {
                _ = try await instructorService.addInstructor(to: UUID(), userId: userId)
            }
        }
    }

    @Test("Test Add Duplicate Instructor Throws Error")
    func testAddDuplicateInstructor() async throws {
        try await withApp { app in
            let instructorService = InstructorService(database: app.db)

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

            _ = try await instructorService.addInstructor(to: stationId, userId: userId)

            await #expect(throws: InstructorError.uniqueViolation(field: .instructor)) {
                _ = try await instructorService.addInstructor(to: stationId, userId: userId)
            }
        }
    }

    @Test("Test Delete Instructor")
    func testDeleteInstructor() async throws {
        try await withApp { app in
            let instructorService = InstructorService(database: app.db)

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

            try await instructorService.deleteInstructor(userId: userId, stationId: stationId)

            let found = try await Instructor.find(instructor.id, on: app.db)
            #expect(found == nil)
        }
    }

    @Test("Test Deleting Already Existing User Does Not Throw")
    func testDeleteNotExistantInstructor() async throws {
        try await withApp { app in
            let instructorService = InstructorService(database: app.db)

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

            try await instructorService.deleteInstructor(userId: UUID(), stationId: UUID())
        }
    }
}
