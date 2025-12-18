import Fluent
import Testing
import VaporTesting

@testable import MembersServer

private enum InstructorsControllerTestHelper {
    static func sampleStation(name: String = "Test Station") -> Station {
        Station(name: name)
    }

    static func sampleUser(firstName: String = "Test", lastName: String = "User", email: String = "test@example.com") -> User {
        User(firstName: firstName, lastName: lastName, email: email)
    }

    static func sampleAdminUser() -> User {
        User(firstName: "Admin", lastName: "User", email: "admin@test.com")
    }

    static func sampleInstructorRequestDTO(userId: UUID) -> InstructorRequestDTO {
        InstructorRequestDTO(userId: userId)
    }
}

@Suite("InstructorsController Tests", .serialized)
struct InstructorsControllerTests {

    // MARK: - Add Instructor Tests

    @Test("Add Instructor - Success (Admin)")
    func testAddInstructorSuccess() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)

            let adminUser = try await userService.createUser(from: InstructorsControllerTestHelper.sampleAdminUser())
            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminUser.$roles.create(adminRole, on: app.db)
            let headers = try await app.getTokenHeader(for: adminUser)

            let station = InstructorsControllerTestHelper.sampleStation()
            try await station.save(on: app.db)
            guard let stationId = station.id else {
                #expect(Bool(false), "Station ID was nil")
                return
            }

            let user = try await userService.createUser(from: InstructorsControllerTestHelper.sampleUser())
            guard let userId = user.id else {
                #expect(Bool(false), "User ID was nil")
                return
            }

            let dto = InstructorsControllerTestHelper.sampleInstructorRequestDTO(userId: userId)

            try await app.testing().test(
                .POST, "/v1/stations/\(stationId)/instructors",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(dto)
                }
            ) { res in
                #expect(res.status == .ok)
                let instructorDTO = try res.content.decode(InstructorDTO.self)
                #expect(instructorDTO.firstName == user.firstName)
                #expect(instructorDTO.lastName == user.lastName)
                #expect(instructorDTO.email == user.email)

                let savedInstructor = try await Instructor.find(instructorDTO.userId, on: app.db)
                #expect(savedInstructor != nil)
                #expect(savedInstructor?.$user.id == userId)
                #expect(savedInstructor?.$station.id == stationId)
            }
        }
    }

    @Test("Add Instructor - Non-Admin Returns Forbidden")
    func testAddInstructorNonAdminForbidden() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)

            let user = try await userService.createUser(from: InstructorsControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)

            let station = InstructorsControllerTestHelper.sampleStation()
            try await station.save(on: app.db)
            guard let stationId = station.id else { return }

            let dto = InstructorsControllerTestHelper.sampleInstructorRequestDTO(userId: user.id!)

            try await app.testing().test(
                .POST, "/v1/stations/\(stationId)/instructors",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(dto)
                }
            ) { res in
                #expect(res.status == .forbidden)
            }
        }
    }

    @Test("Add Instructor - Unauthorized Without Token")
    func testAddInstructorUnauthorized() async throws {
        try await withApp { app in
            let station = InstructorsControllerTestHelper.sampleStation()
            try await station.save(on: app.db)
            guard let stationId = station.id else { return }

            let dto = InstructorsControllerTestHelper.sampleInstructorRequestDTO(userId: UUID())

            try await app.testing().test(
                .POST, "/v1/stations/\(stationId)/instructors",
                beforeRequest: { req in
                    try req.content.encode(dto)
                }
            ) { res in
                #expect(res.status == .unauthorized)
            }
        }
    }

    @Test("Add Instructor - Invalid Station UUID Returns Bad Request")
    func testAddInstructorInvalidStationUUID() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)

            let adminUser = try await userService.createUser(from: InstructorsControllerTestHelper.sampleAdminUser())
            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminUser.$roles.create(adminRole, on: app.db)
            let headers = try await app.getTokenHeader(for: adminUser)

            let dto = InstructorsControllerTestHelper.sampleInstructorRequestDTO(userId: UUID())

            try await app.testing().test(
                .POST, "/v1/stations/invalid-uuid/instructors",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(dto)
                }
            ) { res in
                #expect(res.status == .badRequest)
            }
        }
    }

    // MARK: - Delete Instructor Tests

    @Test("Delete Instructor - Success (Admin)")
    func testDeleteInstructorSuccess() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let adminLogger = AdminLogService(database: app.db)
            let instructorService = InstructorService(database: app.db, adminLogger: adminLogger)

            let adminUser = try await userService.createUser(from: InstructorsControllerTestHelper.sampleAdminUser())
            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminUser.$roles.create(adminRole, on: app.db)
            let headers = try await app.getTokenHeader(for: adminUser)

            let station = InstructorsControllerTestHelper.sampleStation()
            try await station.save(on: app.db)
            guard let stationId = station.id else { return }

            let user = try await userService.createUser(from: InstructorsControllerTestHelper.sampleUser())
            let instructorDTO = try await instructorService.addInstructor(asUser: try user.requireId(), to: stationId, userId: user.id!)

            try await app.testing().test(
                .DELETE, "/v1/stations/\(stationId)/instructors/\(instructorDTO.userId)",
                headers: headers
            ) { res in
                #expect(res.status == .noContent)

                let found = try await Instructor.query(on: app.db)
                    .filter(\.$user.$id == instructorDTO.userId)
                    .filter(\.$station.$id == stationId)
                    .first()
                #expect(found == nil)
            }
        }
    }

    @Test("Delete Instructor - Non-Admin Returns Forbidden")
    func testDeleteInstructorNonAdminForbidden() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let adminLogger = AdminLogService(database: app.db)
            let instructorService = InstructorService(database: app.db, adminLogger: adminLogger)

            let user = try await userService.createUser(from: InstructorsControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)

            let station = InstructorsControllerTestHelper.sampleStation()
            try await station.save(on: app.db)
            guard let stationId = station.id else { return }

            let instructorUser = try await userService.createUser(from: User(firstName: "Inst", lastName: "User", email: "inst@test.com"))
            _ = try await instructorService.addInstructor(asUser: try user.requireId(), to: stationId, userId: instructorUser.id!)

            try await app.testing().test(
                .DELETE, "/v1/stations/\(stationId)/instructors/\(instructorUser.id!)",
                headers: headers
            ) { res in
                #expect(res.status == .forbidden)
            }
        }
    }

    @Test("Delete Instructor - Unauthorized Without Token")
    func testDeleteInstructorUnauthorized() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let adminLogger = AdminLogService(database: app.db)
            let instructorService = InstructorService(database: app.db, adminLogger: adminLogger)

            let station = InstructorsControllerTestHelper.sampleStation()
            try await station.save(on: app.db)
            guard let stationId = station.id else { return }

            let user = try await userService.createUser(from: InstructorsControllerTestHelper.sampleUser())
            _ = try await instructorService.addInstructor(asUser: try user.requireId(), to: stationId, userId: user.id!)

            try await app.testing().test(
                .DELETE, "/v1/stations/\(stationId)/instructors/\(user.id!)"
            ) { res in
                #expect(res.status == .unauthorized)
            }
        }
    }

    @Test("Delete Instructor - Invalid UUID Returns Bad Request")
    func testDeleteInstructorInvalidUUID() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)

            let adminUser = try await userService.createUser(from: InstructorsControllerTestHelper.sampleAdminUser())
            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminUser.$roles.create(adminRole, on: app.db)
            let headers = try await app.getTokenHeader(for: adminUser)

            let station = InstructorsControllerTestHelper.sampleStation()
            try await station.save(on: app.db)
            guard let stationId = station.id else { return }

            try await app.testing().test(
                .DELETE, "/v1/stations/\(stationId)/instructors/invalid-uuid",
                headers: headers
            ) { res in
                #expect(res.status == .badRequest)
            }
        }
    }
}
