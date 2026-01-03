import Fluent
import Testing
import VaporTesting

@testable import MembersServer

private enum UserBadgesControllerTestHelper {
    static func sampleStation(name: String = "Test Station") -> Station {
        Station(name: name)
    }

    static func sampleBadge(name: String = "Test Badge", stationId: UUID) -> Badge {
        Badge(
            name: name,
            description: "Test badge description",
            imageUrlString: "https://example.com/badge.png",
            stationId: stationId
        )
    }

    static func sampleUser(email: String = "user@test.com") -> User {
        User(firstName: "Test", lastName: "User", email: email)
    }

    static func sampleInstructorUser(email: String = "instructor@test.com") -> User {
        User(firstName: "Instructor", lastName: "User", email: email)
    }

    static func sampleUserBadgeRequestDTO(badgeId: UUID) -> UserBadgeRequestDTO {
        UserBadgeRequestDTO(badgeId: badgeId)
    }
}

@Suite("UserBadgesController Tests", .serialized)
struct UserBadgesControllerTests {

    // MARK: - Add Badge Tests

    @Test("Add Badge - Success (Instructor)")
    func testAddBadgeSuccess() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)

            let station = UserBadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let instructor = try await userService.createUser(
                from: UserBadgesControllerTestHelper.sampleInstructorUser())
            let instructorRole = Instructor(userID: instructor.id!, stationID: station.id!)
            try await instructorRole.save(on: app.db)

            let headers = try await app.getTokenHeader(for: instructor)

            let recipient = try await userService.createUser(
                from: UserBadgesControllerTestHelper.sampleUser())

            let badge = UserBadgesControllerTestHelper.sampleBadge(stationId: station.id!)
            try await badge.save(on: app.db)

            let requestDTO = UserBadgesControllerTestHelper.sampleUserBadgeRequestDTO(badgeId: badge.id!)

            try await app.testing().test(
                .POST,
                "/v1/users/\(recipient.id!.uuidString)/badges",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(requestDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .ok)
                    let body = try res.content.decode(UserBadgeDTO.self)
                    #expect(body.badgeId == badge.id)
                    #expect(body.name == badge.name)
                    #expect(body.station.id == station.id)
                }
            )

            let userBadge = try await UserBadge.query(on: app.db)
                .filter(\.$user.$id == recipient.id!)
                .filter(\.$badge.$id == badge.id!)
                .first()
            #expect(userBadge != nil)
        }
    }

    @Test("Add Badge - Forbidden (Non-Instructor)")
    func testAddBadgeNonInstructorForbidden() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)

            let station = UserBadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let otherStation = UserBadgesControllerTestHelper.sampleStation(name: "Other Station")
            try await otherStation.save(on: app.db)

            let user = try await userService.createUser(
                from: UserBadgesControllerTestHelper.sampleInstructorUser())
            // Made them instructor for WRONG station
            let userRole = Instructor(userID: user.id!, stationID: otherStation.id!)
            try await userRole.save(on: app.db)

            let headers = try await app.getTokenHeader(for: user)

            let recipient = try await userService.createUser(
                from: UserBadgesControllerTestHelper.sampleUser())

            let badge = UserBadgesControllerTestHelper.sampleBadge(stationId: station.id!)
            try await badge.save(on: app.db)

            let requestDTO = UserBadgesControllerTestHelper.sampleUserBadgeRequestDTO(badgeId: badge.id!)

            try await app.testing().test(
                .POST,
                "/v1/users/\(recipient.id!.uuidString)/badges",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(requestDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .forbidden)
                }
            )
        }
    }

    @Test("Add Badge - Unauthorized Without Token")
    func testAddBadgeUnauthorized() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let station = UserBadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let recipient = try await userService.createUser(
                from: UserBadgesControllerTestHelper.sampleUser())
            let badge = UserBadgesControllerTestHelper.sampleBadge(stationId: station.id!)
            try await badge.save(on: app.db)

            let requestDTO = UserBadgesControllerTestHelper.sampleUserBadgeRequestDTO(badgeId: badge.id!)

            try await app.testing().test(
                .POST,
                "/v1/users/\(recipient.id!.uuidString)/badges",
                beforeRequest: { req in
                    try req.content.encode(requestDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .unauthorized)
                }
            )
        }
    }

    @Test("Add Badge - Badge Not Found")
    func testAddBadgeBadgeNotFound() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)

            let station = UserBadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let instructor = try await userService.createUser(from: UserBadgesControllerTestHelper.sampleInstructorUser())
            let instructorRole = Instructor(userID: instructor.id!, stationID: station.id!)
            try await instructorRole.save(on: app.db)
            let headers = try await app.getTokenHeader(for: instructor)

            let recipient = try await userService.createUser(from: UserBadgesControllerTestHelper.sampleUser())

            let requestDTO = UserBadgesControllerTestHelper.sampleUserBadgeRequestDTO(badgeId: UUID())

            try await app.testing().test(
                .POST,
                "/v1/users/\(recipient.id!.uuidString)/badges",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(requestDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .notFound)
                }
            )
        }
    }

    @Test("Add Badge - Duplicate Returns Conflict")
    func testAddBadgeDuplicate() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)

            let station = UserBadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let instructor = try await userService.createUser(from: UserBadgesControllerTestHelper.sampleInstructorUser())
            let instructorRole = Instructor(userID: instructor.id!, stationID: station.id!)
            try await instructorRole.save(on: app.db)
            let headers = try await app.getTokenHeader(for: instructor)

            let recipient = try await userService.createUser(from: UserBadgesControllerTestHelper.sampleUser())
            let badge = UserBadgesControllerTestHelper.sampleBadge(stationId: station.id!)
            try await badge.save(on: app.db)

            let userBadge = UserBadge(badgeId: badge.id!, userId: recipient.id!)
            try await userBadge.save(on: app.db)

            let requestDTO = UserBadgesControllerTestHelper.sampleUserBadgeRequestDTO(badgeId: badge.id!)

            try await app.testing().test(
                .POST,
                "/v1/users/\(recipient.id!.uuidString)/badges",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(requestDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .conflict)
                }
            )
        }
    }

    // MARK: - Delete Badge Tests

    @Test("Delete Badge - Success (Instructor)")
    func testDeleteBadgeSuccess() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)

            let station = UserBadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let instructor = try await userService.createUser(from: UserBadgesControllerTestHelper.sampleInstructorUser())
            let instructorRole = Instructor(userID: instructor.id!, stationID: station.id!)
            try await instructorRole.save(on: app.db)
            let headers = try await app.getTokenHeader(for: instructor)

            let recipient = try await userService.createUser(from: UserBadgesControllerTestHelper.sampleUser())
            let badge = UserBadgesControllerTestHelper.sampleBadge(stationId: station.id!)
            try await badge.save(on: app.db)

            let userBadge = UserBadge(badgeId: badge.id!, userId: recipient.id!)
            try await userBadge.save(on: app.db)

            try await app.testing().test(
                .DELETE,
                "/v1/users/\(recipient.id!.uuidString)/badges/\(badge.id!.uuidString)",
                headers: headers
            ) { res in
                #expect(res.status == .noContent)
            }

            let found = try await UserBadge.query(on: app.db)
                .filter(\.$user.$id == recipient.id!)
                .filter(\.$badge.$id == badge.id!)
                .first()
            #expect(found == nil)
        }
    }

    @Test("Delete Badge - Forbidden (Non-Instructor)")
    func testDeleteBadgeNonInstructorForbidden() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)

            let station = UserBadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let otherStation = UserBadgesControllerTestHelper.sampleStation(name: "Other")
            try await otherStation.save(on: app.db)

            let user = try await userService.createUser(from: UserBadgesControllerTestHelper.sampleInstructorUser())
            let userRole = Instructor(userID: user.id!, stationID: otherStation.id!)
            try await userRole.save(on: app.db)
            let headers = try await app.getTokenHeader(for: user)

            let recipient = try await userService.createUser(from: UserBadgesControllerTestHelper.sampleUser())
            let badge = UserBadgesControllerTestHelper.sampleBadge(stationId: station.id!)
            try await badge.save(on: app.db)

            let userBadge = UserBadge(badgeId: badge.id!, userId: recipient.id!)
            try await userBadge.save(on: app.db)

            try await app.testing().test(
                .DELETE,
                "/v1/users/\(recipient.id!.uuidString)/badges/\(badge.id!.uuidString)",
                headers: headers
            ) { res in
                #expect(res.status == .forbidden)
            }
        }
    }

    @Test("Delete Badge - Unauthorized Without Token")
    func testDeleteBadgeUnauthorized() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let station = UserBadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let recipient = try await userService.createUser(from: UserBadgesControllerTestHelper.sampleUser())
            let badge = UserBadgesControllerTestHelper.sampleBadge(stationId: station.id!)
            try await badge.save(on: app.db)

            let userBadge = UserBadge(badgeId: badge.id!, userId: recipient.id!)
            try await userBadge.save(on: app.db)

            try await app.testing().test(
                .DELETE,
                "/v1/users/\(recipient.id!.uuidString)/badges/\(badge.id!.uuidString)"
            ) { res in
                #expect(res.status == .unauthorized)
            }
        }
    }

    @Test("Delete Badge - Badge Not Found")
    func testDeleteBadgeBadgeNotFound() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let station = UserBadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let instructor = try await userService.createUser(from: UserBadgesControllerTestHelper.sampleInstructorUser())
            let instructorRole = Instructor(userID: instructor.id!, stationID: station.id!)
            try await instructorRole.save(on: app.db)
            let headers = try await app.getTokenHeader(for: instructor)

            let recipient = try await userService.createUser(from: UserBadgesControllerTestHelper.sampleUser())

            try await app.testing().test(
                .DELETE,
                "/v1/users/\(recipient.id!.uuidString)/badges/\(UUID().uuidString)",
                headers: headers
            ) { res in
                #expect(res.status == .notFound)
            }
        }
    }
}
