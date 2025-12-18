import Fluent
import Testing
import VaporTesting

@testable import MembersServer

private enum StationsControllerTestHelper {
    static func sampleStationDTO(name: String = "Test Station") -> StationRequestDTO {
        StationRequestDTO(name: name)
    }

    static func sampleUser() -> User {
        User(firstName: "Station", lastName: "Controller", email: "stationcontroller@test.com")
    }

    static func sampleAdminUser() -> User {
        User(firstName: "Admin", lastName: "User", email: "admin@test.com")
    }
}

@Suite("StationsController Tests", .serialized)
struct StationsControllerTests {
    // MARK: - Get Station Tests

    @Test("Get Station by ID - Success")
    func testGetStationByIDSuccess() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let adminLogService = AdminLogService(database: app.db)
            let stationService = StationService(database: app.db, adminLogger: adminLogService)

            let user = try await userService.createUser(from: StationsControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)
            
            // Create admin user for station creation
            let adminUser = try await userService.createUser(from: StationsControllerTestHelper.sampleAdminUser())

            let stationDTO = StationsControllerTestHelper.sampleStationDTO()
            let station = try await stationService.addStation(asUser: adminUser.requireID(), from: stationDTO)

            try await app.testing().test(
                .GET,
                "/v1/stations/\(station.stationId.uuidString)",
                headers: headers
            ) { res in
                #expect(res.status == .ok)
                let body = try res.content.decode(StationResponseDTO.self)
                #expect(body.stationId == station.stationId)
                #expect(body.stationName == station.stationName)
            }
        }
    }

    @Test("Get Not Found Station Returns Not Found")
    func testGetNotFoundStation() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let user = try await userService.createUser(from: StationsControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)

            try await app.testing().test(
                .GET, "/v1/stations/\(UUID().uuidString)", headers: headers
            ) { res in
                #expect(res.status == .notFound)
            }
        }
    }

    @Test("Get Station - Invalid UUID Returns Bad Request")
    func testGetStationInvalidUUID() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let user = try await userService.createUser(from: StationsControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)

            try await app.testing().test(.GET, "/v1/stations/invalid-uuid", headers: headers) { res in
                #expect(res.status == .badRequest)
            }
        }
    }

    @Test("Get Station - Unauthorized Without Token")
    func testGetStationUnauthorized() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let adminLogService = AdminLogService(database: app.db)
            let stationService = StationService(database: app.db, adminLogger: adminLogService)
            
            let adminUser = try await userService.createUser(from: StationsControllerTestHelper.sampleAdminUser())

            let stationDTO = StationsControllerTestHelper.sampleStationDTO()
            let station = try await stationService.addStation(asUser: adminUser.requireID(), from: stationDTO)

            try await app.testing().test(
                .GET, "/v1/stations/\(station.stationId.uuidString)"
            ) { res in
                #expect(res.status == .unauthorized)
            }
        }
    }

    // MARK: - Get Stations Tests

    @Test("Get Stations - Returns List")
    func testGetStationsSuccess() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let adminLogService = AdminLogService(database: app.db)
            let stationService = StationService(database: app.db, adminLogger: adminLogService)

            let user = try await userService.createUser(from: StationsControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)
            
            let adminUser = try await userService.createUser(from: StationsControllerTestHelper.sampleAdminUser())

            _ = try await stationService.addStation(
                asUser: adminUser.requireID(),
                from: StationsControllerTestHelper.sampleStationDTO(name: "Station 1"))
            _ = try await stationService.addStation(
                asUser: adminUser.requireID(),
                from: StationsControllerTestHelper.sampleStationDTO(name: "Station 2"))
            _ = try await stationService.addStation(
                asUser: adminUser.requireID(),
                from: StationsControllerTestHelper.sampleStationDTO(name: "Station 3"))

            try await app.testing().test(.GET, "/v1/stations", headers: headers) { res in
                #expect(res.status == .ok)
                let body = try res.content.decode([StationListResponseDTO].self)
                #expect(body.count == 3)
            }
        }
    }

    @Test("Get Stations - Unauthorized Without Token")
    func testGetStationsUnauthorized() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let adminLogService = AdminLogService(database: app.db)
            let stationService = StationService(database: app.db, adminLogger: adminLogService)
            
            let adminUser = try await userService.createUser(from: StationsControllerTestHelper.sampleAdminUser())

            _ = try await stationService.addStation(
                asUser: adminUser.requireID(),
                from: StationsControllerTestHelper.sampleStationDTO(name: "Station 1"))

            try await app.testing().test(.GET, "/v1/stations") { res in
                #expect(res.status == .unauthorized)
            }
        }
    }

    // MARK: - Add Station Tests

    @Test("Add Station - Success (Admin)")
    func testAddStationSuccess() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let adminUser = try await userService.createUser(
                from: StationsControllerTestHelper.sampleAdminUser())

            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminUser.$roles.create(adminRole, on: app.db)

            let headers = try await app.getTokenHeader(for: adminUser)

            let stationDTO = StationsControllerTestHelper.sampleStationDTO()

            try await app.testing().test(
                .POST,
                "/v1/stations",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(stationDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .ok)
                    let body = try res.content.decode(StationResponseDTO.self)
                    #expect(body.stationName == stationDTO.name)
                }
            )
        }
    }

    @Test("Add Station - Non-Admin Returns Forbidden")
    func testAddStationNonAdminForbidden() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let user = try await userService.createUser(from: StationsControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)

            let stationDTO = StationsControllerTestHelper.sampleStationDTO()

            try await app.testing().test(
                .POST,
                "/v1/stations",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(stationDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .forbidden)
                }
            )
        }
    }

    @Test("Add Station - Unauthorized Without Token")
    func testAddStationUnauthorized() async throws {
        try await withApp { app in
            let stationDTO = StationsControllerTestHelper.sampleStationDTO()

            try await app.testing().test(
                .POST,
                "/v1/stations",
                beforeRequest: { req in
                    try req.content.encode(stationDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .unauthorized)
                }
            )
        }
    }

    @Test("Add Station - Duplicate Name Returns Conflict")
    func testAddStationDuplicateName() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let adminLogService = AdminLogService(database: app.db)
            let stationService = StationService(database: app.db, adminLogger: adminLogService)

            let adminUser = try await userService.createUser(
                from: StationsControllerTestHelper.sampleAdminUser())
            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminUser.$roles.create(adminRole, on: app.db)
            let headers = try await app.getTokenHeader(for: adminUser)

            _ = try await stationService.addStation(
                asUser: adminUser.requireID(),
                from: StationsControllerTestHelper.sampleStationDTO(name: "Duplicate Name"))

            let duplicateDTO = StationsControllerTestHelper.sampleStationDTO(
                name: "Duplicate Name")

            try await app.testing().test(
                .POST,
                "/v1/stations",
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

    // MARK: - Update Station Tests

    @Test("Update Station - Success (Admin)")
    func testUpdateStationSuccess() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let adminLogService = AdminLogService(database: app.db)
            let stationService = StationService(database: app.db, adminLogger: adminLogService)

            let adminUser = try await userService.createUser(
                from: StationsControllerTestHelper.sampleAdminUser())
            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminUser.$roles.create(adminRole, on: app.db)
            let headers = try await app.getTokenHeader(for: adminUser)

            let stationDTO = StationsControllerTestHelper.sampleStationDTO()
            let station = try await stationService.addStation(asUser: adminUser.requireID(), from: stationDTO)

            let updateDTO = StationRequestDTO(name: "Updated Station Name")

            try await app.testing().test(
                .PUT,
                "/v1/stations/\(station.stationId.uuidString)",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(updateDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .ok)
                    let body = try res.content.decode(StationResponseDTO.self)
                    #expect(body.stationId == station.stationId)
                    #expect(body.stationName == "Updated Station Name")
                }
            )
        }
    }

    @Test("Update Station - Non-Admin Returns Forbidden")
    func testUpdateStationNonAdminForbidden() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let adminLogService = AdminLogService(database: app.db)
            let stationService = StationService(database: app.db, adminLogger: adminLogService)

            let user = try await userService.createUser(from: StationsControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)
            
            let adminUser = try await userService.createUser(from: StationsControllerTestHelper.sampleAdminUser())

            let stationDTO = StationsControllerTestHelper.sampleStationDTO()
            let station = try await stationService.addStation(asUser: adminUser.requireID(), from: stationDTO)

            let updateDTO = StationRequestDTO(name: "Updated Station Name")

            try await app.testing().test(
                .PUT,
                "/v1/stations/\(station.stationId.uuidString)",
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

    @Test("Update Station - Invalid UUID Returns Bad Request")
    func testUpdateStationInvalidUUID() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let adminUser = try await userService.createUser(
                from: StationsControllerTestHelper.sampleAdminUser())
            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminUser.$roles.create(adminRole, on: app.db)
            let headers = try await app.getTokenHeader(for: adminUser)

            let updateDTO = StationsControllerTestHelper.sampleStationDTO()

            try await app.testing().test(
                .PUT,
                "/v1/stations/invalid-uuid",
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

    @Test("Update Station - Unauthorized Without Token")
    func testUpdateStationUnauthorized() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let adminLogService = AdminLogService(database: app.db)
            let stationService = StationService(database: app.db, adminLogger: adminLogService)
            
            let adminUser = try await userService.createUser(from: StationsControllerTestHelper.sampleAdminUser())

            let stationDTO = StationsControllerTestHelper.sampleStationDTO()
            let station = try await stationService.addStation(asUser: adminUser.requireID(), from: stationDTO)

            let updateDTO = StationRequestDTO(name: "Updated Station Name")

            try await app.testing().test(
                .PUT,
                "/v1/stations/\(station.stationId.uuidString)",
                beforeRequest: { req in
                    try req.content.encode(updateDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .unauthorized)
                }
            )
        }
    }

    @Test("Update Station - Not Found Returns Not Found")
    func testUpdateStationNotFound() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let adminUser = try await userService.createUser(
                from: StationsControllerTestHelper.sampleAdminUser())
            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminUser.$roles.create(adminRole, on: app.db)
            let headers = try await app.getTokenHeader(for: adminUser)

            let updateDTO = StationsControllerTestHelper.sampleStationDTO()

            try await app.testing().test(
                .PUT,
                "/v1/stations/\(UUID().uuidString)",
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

    // MARK: - Delete Station Tests

    @Test("Delete Station - Success (Admin)")
    func testDeleteStationSuccess() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let adminLogService = AdminLogService(database: app.db)
            let stationService = StationService(database: app.db, adminLogger: adminLogService)

            let adminUser = try await userService.createUser(
                from: StationsControllerTestHelper.sampleAdminUser())
            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminUser.$roles.create(adminRole, on: app.db)
            let headers = try await app.getTokenHeader(for: adminUser)

            let stationDTO = StationsControllerTestHelper.sampleStationDTO()
            let station = try await stationService.addStation(asUser: adminUser.requireID(), from: stationDTO)

            try await app.testing().test(
                .DELETE,
                "/v1/stations/\(station.stationId.uuidString)",
                headers: headers
            ) { res in
                #expect(res.status == .noContent)
            }

            let found = try await Station.find(station.stationId, on: app.db)
            #expect(found == nil)
        }
    }

    @Test("Delete Station - Non-Admin Returns Forbidden")
    func testDeleteStationNonAdminForbidden() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let adminLogService = AdminLogService(database: app.db)
            let stationService = StationService(database: app.db, adminLogger: adminLogService)

            let user = try await userService.createUser(from: StationsControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)
            
            let adminUser = try await userService.createUser(from: StationsControllerTestHelper.sampleAdminUser())

            let stationDTO = StationsControllerTestHelper.sampleStationDTO()
            let station = try await stationService.addStation(asUser: adminUser.requireID(), from: stationDTO)

            try await app.testing().test(
                .DELETE,
                "/v1/stations/\(station.stationId.uuidString)",
                headers: headers
            ) { res in
                #expect(res.status == .forbidden)
            }

            let found = try await Station.find(station.stationId, on: app.db)
            #expect(found != nil)
        }
    }

    @Test("Delete Station - Invalid UUID Returns Bad Request")
    func testDeleteStationInvalidUUID() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let adminUser = try await userService.createUser(
                from: StationsControllerTestHelper.sampleAdminUser())
            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminUser.$roles.create(adminRole, on: app.db)
            let headers = try await app.getTokenHeader(for: adminUser)

            try await app.testing().test(
                .DELETE, "/v1/stations/invalid-uuid", headers: headers
            ) { res in
                #expect(res.status == .badRequest)
            }
        }
    }

    @Test("Delete Station - Unauthorized Without Token")
    func testDeleteStationUnauthorized() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let adminLogService = AdminLogService(database: app.db)
            let stationService = StationService(database: app.db, adminLogger: adminLogService)
            
            let adminUser = try await userService.createUser(from: StationsControllerTestHelper.sampleAdminUser())

            let stationDTO = StationsControllerTestHelper.sampleStationDTO()
            let station = try await stationService.addStation(asUser: adminUser.requireID(), from: stationDTO)

            try await app.testing().test(.DELETE, "/v1/stations/\(station.stationId.uuidString)") { res in
                #expect(res.status == .unauthorized)
            }
        }
    }
}
