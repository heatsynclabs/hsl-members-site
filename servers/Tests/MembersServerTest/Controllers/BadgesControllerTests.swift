import Fluent
import Testing
import VaporTesting

@testable import MembersServer

private enum BadgesControllerTestHelper {
    static func sampleStation(name: String = "Test Station") -> Station {
        Station(name: name)
    }

    static func sampleBadgeDTO(name: String = "Test Badge", stationId: UUID) -> BadgeRequestDTO {
        BadgeRequestDTO(
            name: name,
            description: "Test badge description",
            imageURL: "https://example.com/badge.png",
            stationId: stationId
        )
    }

    static func sampleUser() -> User {
        User(firstName: "Badge", lastName: "Controller", email: "badgecontroller@test.com")
    }

    static func sampleAdminUser() -> User {
        User(firstName: "Admin", lastName: "User", email: "admin@test.com")
    }
}

@Suite("BadgesController Tests", .serialized)
struct BadgesControllerTests {
    // MARK: - Get Badge Tests

    @Test("Get Badge by ID - Success")
    func testGetBadgeByIDSuccess() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let user = try await userService.createUser(from: BadgesControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)

            let station = BadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let badgeDTO = BadgesControllerTestHelper.sampleBadgeDTO(stationId: station.id!)
            let badge = try await badgeService.addBadge(from: badgeDTO)

            try await app.testing().test(
                .GET,
                "/v1/badges/\(badge.id.uuidString)",
                headers: headers
            ) { res in
                #expect(res.status == .ok)
                let body = try res.content.decode(BadgeResponseDTO.self)
                #expect(body.id == badge.id)
                #expect(body.name == badge.name)
                #expect(body.description == badge.description)
                #expect(body.station.id == station.id)
            }
        }
    }

    @Test("Get Not Found Badge Returns Not Found")
    func testGetNotFoundBadge() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let user = try await userService.createUser(from: BadgesControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)

            try await app.testing().test(
                .GET, "/v1/badges/\(UUID().uuidString)", headers: headers
            ) { res in
                #expect(res.status == .notFound)
            }
        }
    }

    @Test("Get Badge - Invalid UUID Returns Bad Request")
    func testGetBadgeInvalidUUID() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let user = try await userService.createUser(from: BadgesControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)

            try await app.testing().test(.GET, "/v1/badges/invalid-uuid", headers: headers) { res in
                #expect(res.status == .badRequest)
            }
        }
    }

    @Test("Get Badge - Unauthorized Without Token")
    func testGetBadgeUnauthorized() async throws {
        try await withApp { app in
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let station = BadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let badgeDTO = BadgesControllerTestHelper.sampleBadgeDTO(stationId: station.id!)
            let badge = try await badgeService.addBadge(from: badgeDTO)

            try await app.testing().test(
                .GET, "/v1/badges/\(badge.id.uuidString)"
            ) { res in
                #expect(res.status == .unauthorized)
            }
        }
    }

    // MARK: - Get Badges Tests

    @Test("Get Badges - Returns List")
    func testGetBadgesSuccess() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let user = try await userService.createUser(from: BadgesControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)

            let station1 = BadgesControllerTestHelper.sampleStation(name: "Station 1")
            let station2 = BadgesControllerTestHelper.sampleStation(name: "Station 2")
            let station3 = BadgesControllerTestHelper.sampleStation(name: "Station 3")
            try await [station1, station2, station3].create(on: app.db)

            _ = try await badgeService.addBadge(
                from: BadgesControllerTestHelper.sampleBadgeDTO(name: "Badge 1", stationId: station1.id!))
            _ = try await badgeService.addBadge(
                from: BadgesControllerTestHelper.sampleBadgeDTO(name: "Badge 2", stationId: station2.id!))
            _ = try await badgeService.addBadge(
                from: BadgesControllerTestHelper.sampleBadgeDTO(name: "Badge 3", stationId: station3.id!))

            try await app.testing().test(.GET, "/v1/badges", headers: headers) { res in
                #expect(res.status == .ok)
                let body = try res.content.decode([BadgeResponseDTO].self)
                #expect(body.count == 3)
            }
        }
    }

    @Test("Get Badges - Unauthorized Without Token")
    func testGetBadgesUnauthorized() async throws {
        try await withApp { app in
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let station1 = BadgesControllerTestHelper.sampleStation(name: "Station 1")
            try await station1.save(on: app.db)
            _ = try await badgeService.addBadge(
                from: BadgesControllerTestHelper.sampleBadgeDTO(name: "Badge 1", stationId: station1.id!))

            try await app.testing().test(.GET, "/v1/badges") { res in
                #expect(res.status == .unauthorized)
            }
        }
    }

    // MARK: - Add Badge Tests

    @Test("Add Badge - Success (Admin)")
    func testAddBadgeSuccess() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let adminUser = try await userService.createUser(
                from: BadgesControllerTestHelper.sampleAdminUser())

            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminUser.$roles.create(adminRole, on: app.db)

            let headers = try await app.getTokenHeader(for: adminUser)

            let station = BadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let badgeDTO = BadgesControllerTestHelper.sampleBadgeDTO(stationId: station.id!)

            try await app.testing().test(
                .POST,
                "/v1/badges",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(badgeDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .ok)
                    let body = try res.content.decode(BadgeResponseDTO.self)
                    #expect(body.name == badgeDTO.name)
                    #expect(body.description == badgeDTO.description)
                    #expect(body.station.id == station.id)
                }
            )
        }
    }

    @Test("Add Badge - Non-Admin Returns Forbidden")
    func testAddBadgeNonAdminForbidden() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let user = try await userService.createUser(from: BadgesControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)

            let station = BadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let badgeDTO = BadgesControllerTestHelper.sampleBadgeDTO(stationId: station.id!)

            try await app.testing().test(
                .POST,
                "/v1/badges",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(badgeDTO)
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
            let station = BadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let badgeDTO = BadgesControllerTestHelper.sampleBadgeDTO(stationId: station.id!)

            try await app.testing().test(
                .POST,
                "/v1/badges",
                beforeRequest: { req in
                    try req.content.encode(badgeDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .unauthorized)
                }
            )
        }
    }

    @Test("Add Badge - Duplicate Name Returns Conflict")
    func testAddBadgeDuplicateName() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let adminUser = try await userService.createUser(
                from: BadgesControllerTestHelper.sampleAdminUser())
            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminUser.$roles.create(adminRole, on: app.db)
            let headers = try await app.getTokenHeader(for: adminUser)

            let station1 = BadgesControllerTestHelper.sampleStation(name: "Station 1")
            let station2 = BadgesControllerTestHelper.sampleStation(name: "Station 2")
            try await [station1, station2].create(on: app.db)

            _ = try await badgeService.addBadge(
                from: BadgesControllerTestHelper.sampleBadgeDTO(name: "Duplicate Name", stationId: station1.id!))

            let duplicateDTO = BadgesControllerTestHelper.sampleBadgeDTO(
                name: "Duplicate Name", stationId: station2.id!)

            try await app.testing().test(
                .POST,
                "/v1/badges",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(duplicateDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .conflict)
                }
            )
        }
    }

    // MARK: - Update Badge Tests

    @Test("Update Badge - Success (Admin)")
    func testUpdateBadgeSuccess() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let adminUser = try await userService.createUser(
                from: BadgesControllerTestHelper.sampleAdminUser())
            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminUser.$roles.create(adminRole, on: app.db)
            let headers = try await app.getTokenHeader(for: adminUser)

            let station = BadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let badgeDTO = BadgesControllerTestHelper.sampleBadgeDTO(stationId: station.id!)
            let badge = try await badgeService.addBadge(from: badgeDTO)

            let updateDTO = BadgeRequestDTO(
                name: badgeDTO.name,
                description: "Updated description",
                imageURL: "https://example.com/updated.png",
                stationId: station.id!
            )

            try await app.testing().test(
                .PUT,
                "/v1/badges/\(badge.id.uuidString)",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(updateDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .ok)
                    let body = try res.content.decode(BadgeResponseDTO.self)
                    #expect(body.id == badge.id)
                    #expect(body.description == "Updated description")
                    #expect(body.imageURL == "https://example.com/updated.png")
                }
            )
        }
    }

    @Test("Update Badge - Non-Admin Returns Forbidden")
    func testUpdateBadgeNonAdminForbidden() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let user = try await userService.createUser(from: BadgesControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)

            let station = BadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let badgeDTO = BadgesControllerTestHelper.sampleBadgeDTO(stationId: station.id!)
            let badge = try await badgeService.addBadge(from: badgeDTO)

            let updateDTO = BadgeRequestDTO(
                name: badgeDTO.name,
                description: "Updated description",
                imageURL: nil,
                stationId: station.id!
            )

            try await app.testing().test(
                .PUT,
                "/v1/badges/\(badge.id.uuidString)",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(updateDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .forbidden)
                }
            )
        }
    }

    @Test("Update Badge - Invalid UUID Returns Bad Request")
    func testUpdateBadgeInvalidUUID() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let adminUser = try await userService.createUser(
                from: BadgesControllerTestHelper.sampleAdminUser())
            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminUser.$roles.create(adminRole, on: app.db)
            let headers = try await app.getTokenHeader(for: adminUser)

            let station = BadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let updateDTO = BadgesControllerTestHelper.sampleBadgeDTO(stationId: station.id!)

            try await app.testing().test(
                .PUT,
                "/v1/badges/invalid-uuid",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(updateDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .badRequest)
                }
            )
        }
    }

    @Test("Update Badge - Unauthorized Without Token")
    func testUpdateBadgeUnauthorized() async throws {
        try await withApp { app in
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let station = BadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let badgeDTO = BadgesControllerTestHelper.sampleBadgeDTO(stationId: station.id!)
            let badge = try await badgeService.addBadge(from: badgeDTO)

            let updateDTO = BadgeRequestDTO(
                name: badgeDTO.name,
                description: "Updated description",
                imageURL: nil,
                stationId: station.id!
            )

            try await app.testing().test(
                .PUT,
                "/v1/badges/\(badge.id.uuidString)",
                beforeRequest: { req in
                    try req.content.encode(updateDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .unauthorized)
                }
            )
        }
    }

    @Test("Update Badge - Not Found Returns Not Found")
    func testUpdateBadgeNotFound() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let adminUser = try await userService.createUser(
                from: BadgesControllerTestHelper.sampleAdminUser())
            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminUser.$roles.create(adminRole, on: app.db)
            let headers = try await app.getTokenHeader(for: adminUser)

            let station = BadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let updateDTO = BadgesControllerTestHelper.sampleBadgeDTO(stationId: station.id!)

            try await app.testing().test(
                .PUT,
                "/v1/badges/\(UUID().uuidString)",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(updateDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .notFound)
                }
            )
        }
    }

    // MARK: - Delete Badge Tests

    @Test("Delete Badge - Success (Admin)")
    func testDeleteBadgeSuccess() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let adminUser = try await userService.createUser(
                from: BadgesControllerTestHelper.sampleAdminUser())
            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminUser.$roles.create(adminRole, on: app.db)
            let headers = try await app.getTokenHeader(for: adminUser)

            let station = BadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let badgeDTO = BadgesControllerTestHelper.sampleBadgeDTO(stationId: station.id!)
            let badge = try await badgeService.addBadge(from: badgeDTO)

            try await app.testing().test(
                .DELETE,
                "/v1/badges/\(badge.id.uuidString)",
                headers: headers
            ) { res in
                #expect(res.status == .noContent)
            }

            let found = try await Badge.find(badge.id, on: app.db)
            #expect(found == nil)
        }
    }

    @Test("Delete Badge - Non-Admin Returns Forbidden")
    func testDeleteBadgeNonAdminForbidden() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let user = try await userService.createUser(from: BadgesControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)

            let station = BadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let badgeDTO = BadgesControllerTestHelper.sampleBadgeDTO(stationId: station.id!)
            let badge = try await badgeService.addBadge(from: badgeDTO)

            try await app.testing().test(
                .DELETE,
                "/v1/badges/\(badge.id.uuidString)",
                headers: headers
            ) { res in
                #expect(res.status == .forbidden)
            }

            let found = try await Badge.find(badge.id, on: app.db)
            #expect(found != nil)
        }
    }

    @Test("Delete Badge - Invalid UUID Returns Bad Request")
    func testDeleteBadgeInvalidUUID() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let adminUser = try await userService.createUser(
                from: BadgesControllerTestHelper.sampleAdminUser())
            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminUser.$roles.create(adminRole, on: app.db)
            let headers = try await app.getTokenHeader(for: adminUser)

            try await app.testing().test(
                .DELETE, "/v1/badges/invalid-uuid", headers: headers
            ) { res in
                #expect(res.status == .badRequest)
            }
        }
    }

    @Test("Delete Badge - Unauthorized Without Token")
    func testDeleteBadgeUnauthorized() async throws {
        try await withApp { app in
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let station = BadgesControllerTestHelper.sampleStation()
            try await station.save(on: app.db)

            let badgeDTO = BadgesControllerTestHelper.sampleBadgeDTO(stationId: station.id!)
            let badge = try await badgeService.addBadge(from: badgeDTO)

            try await app.testing().test(.DELETE, "/v1/badges/\(badge.id.uuidString)") { res in
                #expect(res.status == .unauthorized)
            }
        }
    }
}
