import Fluent
import Testing
import VaporTesting

@testable import MembersServer

@Suite("User Badge Service Tests", .serialized)
struct UserBadgeServiceTests {

    private static func sampleStation(name: String = "Test Station") -> Station {
        Station(name: name)
    }

    private static func sampleBadge(stationId: UUID, name: String = "Test Badge") -> Badge {
        Badge(name: name, description: "Desc", imageUrlString: nil, stationId: stationId)
    }

    private func createAdminUser(on db: any Database) async throws -> User {
        let user = User(firstName: "Admin", lastName: "User", email: "admin@test.com")
        try await user.save(on: db)
        return user
    }

    private func createStudentUser(on db: any Database, email: String = "student@test.com") async throws -> User {
        let user = User(firstName: "Student", lastName: "User", email: email)
        try await user.save(on: db)
        return user
    }

    private func makeUserInstructor(user: User, station: Station, on db: any Database) async throws {
        let instructor = Instructor(userID: try user.requireID(), stationID: try station.requireID())
        try await instructor.save(on: db)
    }

    private func fetchUserWithInstructors(id: UUID, on db: any Database) async throws -> User {
        guard
            let user = try await User.query(on: db)
                .filter(\.$id == id)
                .with(\.$instructorForStations)
                .first()
        else {
            throw Abort(.notFound)
        }
        return user
    }

    @Test("Test Add Badge Success")
    func testAddBadgeSuccess() async throws {
        try await withApp { app in
            let adminLogService = AdminLogService(database: app.db)
            let userBadgeService = UserBadgeService(database: app.db, adminLogger: adminLogService)

            let station = Self.sampleStation()
            try await station.save(on: app.db)
            let stationId = try station.requireID()

            let badge = Self.sampleBadge(stationId: stationId)
            try await badge.save(on: app.db)
            let badgeId = try badge.requireID()

            let instructorUser = try await createAdminUser(on: app.db)
            try await makeUserInstructor(user: instructorUser, station: station, on: app.db)

            let loadedInstructor = try await fetchUserWithInstructors(id: try instructorUser.requireID(), on: app.db)

            let student = try await createStudentUser(on: app.db)
            let studentId = try student.requireID()

            let userBadgeDTO = try await userBadgeService.addBadge(badgeId, asUser: loadedInstructor, for: studentId)

            #expect(userBadgeDTO.badgeId == badgeId)

            let userBadge = try await UserBadge.query(on: app.db)
                .filter(\.$badge.$id == badgeId)
                .filter(\.$user.$id == studentId)
                .first()

            #expect(userBadge != nil)
        }
    }

    @Test("Test Add Badge Fails If Badge Not Found")
    func testAddBadgeFailsIfBadgeNotFound() async throws {
        try await withApp { app in
            let adminLogService = AdminLogService(database: app.db)
            let userBadgeService = UserBadgeService(database: app.db, adminLogger: adminLogService)

            let instructorUser = try await createAdminUser(on: app.db)
            let student = try await createStudentUser(on: app.db)

            do {
                _ = try await userBadgeService.addBadge(UUID(), asUser: instructorUser, for: try student.requireID())
                #expect(Bool(false), "Should have thrown Abort(.notFound)")
            } catch let error as Abort {
                #expect(error.status == .notFound)
            } catch {
                #expect(Bool(false), "Threw unexpected error: \(error)")
            }
        }
    }

    @Test("Test Add Badge Fails If User Not Instructor")
    func testAddBadgeFailsIfNotInstructor() async throws {
        try await withApp { app in
            let adminLogService = AdminLogService(database: app.db)
            let userBadgeService = UserBadgeService(database: app.db, adminLogger: adminLogService)

            let station = Self.sampleStation()
            try await station.save(on: app.db)
            let badge = Self.sampleBadge(stationId: try station.requireID())
            try await badge.save(on: app.db)

            let regularUser = try await createAdminUser(on: app.db)
            let loadedUser = try await fetchUserWithInstructors(id: try regularUser.requireID(), on: app.db)

            let student = try await createStudentUser(on: app.db)

            await #expect(throws: UserBadgeError.notInstructorForStation) {
                _ = try await userBadgeService.addBadge(try badge.requireID(), asUser: loadedUser, for: try student.requireID())
            }
        }
    }

    @Test("Test Add Badge Fails If Wrong Station Instructor")
    func testAddBadgeFailsIfWrongStationInstructor() async throws {
        try await withApp { app in
            let adminLogService = AdminLogService(database: app.db)
            let userBadgeService = UserBadgeService(database: app.db, adminLogger: adminLogService)

            let station1 = Self.sampleStation(name: "Station 1")
            try await station1.save(on: app.db)
            let badge = Self.sampleBadge(stationId: try station1.requireID())
            try await badge.save(on: app.db)

            let station2 = Self.sampleStation(name: "Station 2")
            try await station2.save(on: app.db)

            let instructorUser = try await createAdminUser(on: app.db)
            try await makeUserInstructor(user: instructorUser, station: station2, on: app.db)
            let loadedInstructor = try await fetchUserWithInstructors(id: try instructorUser.requireID(), on: app.db)

            let student = try await createStudentUser(on: app.db)

            await #expect(throws: UserBadgeError.notInstructorForStation) {
                _ = try await userBadgeService.addBadge(try badge.requireID(), asUser: loadedInstructor, for: try student.requireID())
            }
        }
    }

    @Test("Test Add Badge Duplicate Fails")
    func testAddBadgeDuplicateFails() async throws {
        try await withApp { app in
            let adminLogService = AdminLogService(database: app.db)
            let userBadgeService = UserBadgeService(database: app.db, adminLogger: adminLogService)

            let station = Self.sampleStation()
            try await station.save(on: app.db)
            let badge = Self.sampleBadge(stationId: try station.requireID())
            try await badge.save(on: app.db)
            let badgeId = try badge.requireID()

            let instructorUser = try await createAdminUser(on: app.db)
            try await makeUserInstructor(user: instructorUser, station: station, on: app.db)
            let loadedInstructor = try await fetchUserWithInstructors(id: try instructorUser.requireID(), on: app.db)

            let student = try await createStudentUser(on: app.db)
            let studentId = try student.requireID()

            _ = try await userBadgeService.addBadge(badgeId, asUser: loadedInstructor, for: studentId)

            await #expect(throws: UserBadgeError.uniqueViolation(field: .badge)) {
                _ = try await userBadgeService.addBadge(badgeId, asUser: loadedInstructor, for: studentId)
            }
        }
    }

    @Test("Test Delete Badge Success")
    func testDeleteBadgeSuccess() async throws {
        try await withApp { app in
            let adminLogService = AdminLogService(database: app.db)
            let userBadgeService = UserBadgeService(database: app.db, adminLogger: adminLogService)

            let station = Self.sampleStation()
            try await station.save(on: app.db)
            let badge = Self.sampleBadge(stationId: try station.requireID())
            try await badge.save(on: app.db)
            let badgeId = try badge.requireID()

            let instructorUser = try await createAdminUser(on: app.db)
            try await makeUserInstructor(user: instructorUser, station: station, on: app.db)
            let loadedInstructor = try await fetchUserWithInstructors(id: try instructorUser.requireID(), on: app.db)

            let student = try await createStudentUser(on: app.db)
            let studentId = try student.requireID()

            _ = try await userBadgeService.addBadge(badgeId, asUser: loadedInstructor, for: studentId)

            try await userBadgeService.deleteBadge(badgeId, asUser: loadedInstructor, for: studentId)

            let userBadge = try await UserBadge.query(on: app.db)
                .filter(\.$badge.$id == badgeId)
                .filter(\.$user.$id == studentId)
                .first()
            #expect(userBadge == nil)
        }
    }

    @Test("Test Delete Badge Fails If Not Instructor")
    func testDeleteBadgeFailsIfNotInstructor() async throws {
        try await withApp { app in
            let adminLogService = AdminLogService(database: app.db)
            let userBadgeService = UserBadgeService(database: app.db, adminLogger: adminLogService)

            let station = Self.sampleStation()
            try await station.save(on: app.db)
            let badge = Self.sampleBadge(stationId: try station.requireID())
            try await badge.save(on: app.db)
            let badgeId = try badge.requireID()

            let student = try await createStudentUser(on: app.db)
            let studentId = try student.requireID()
            let userBadge = UserBadge(badgeId: badgeId, userId: studentId)
            try await userBadge.save(on: app.db)

            // Non-instructor user
            let randomUser = try await createAdminUser(on: app.db)
            // Even if we load instructors (empty), it should fail
            let loadedUser = try await fetchUserWithInstructors(id: try randomUser.requireID(), on: app.db)

            await #expect(throws: UserBadgeError.notInstructorForStation) {
                try await userBadgeService.deleteBadge(badgeId, asUser: loadedUser, for: studentId)
            }
        }
    }
}
