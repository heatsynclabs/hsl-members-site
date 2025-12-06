import Fluent
import Testing
import VaporTesting

@testable import MembersServer

private enum UserControllerTestHelper {
    static let sampleUpdateDTO = UserRequestDTO(
        firstName: "Updated",
        lastName: "Person",
        email: "updated@test.com",
        waiverSignedOn: nil,
        emergencyName: nil,
        emergencyPhone: nil,
        emergencyEmail: nil,
        paymentMethod: nil,
        phone: nil,
        currentSkills: nil,
        desiredSkills: nil,
        marketingSource: nil,
        exitReason: nil,
        twitterURL: nil,
        facebookURL: nil,
        githubURL: nil,
        websiteURL: nil,
        emailVisible: true,
        phoneVisible: true,
        postalCode: nil
    )

    static func sampleUser() -> User {
        .init(firstName: "User", lastName: "Controller", email: "usercontroller@test.com")
    }
}

@Suite("UserController Tests", .serialized)
struct UserControllerTests {
    // MARK: - Get User Tests

    @Test("Get User by ID - Success")
    func testGetUserByIDSuccess() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let user = try await userService.createUser(from: UserControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)

            try await app.testing().test(
                .GET,
                "/v1/users/\(user.id?.uuidString ?? "null")",
                headers: headers
            ) { res in
                #expect(res.status == .ok)
                let body = try res.content.decode(UserDetailedResponseDTO.self)
                #expect(body.id == user.id)
                #expect(body.firstName == user.firstName)
                #expect(body.lastName == user.lastName)
                #expect(body.email == user.email)
            }
        }
    }

    @Test("Get Not Found User Returns Not Found")
    func testGetNotFoundUser() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let user = try await userService.createUser(from: UserControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)

            try await app.testing().test(
                .GET, "/v1/users/\(UUID().uuidString)", headers: headers
            ) { res in
                #expect(res.status == .notFound)
            }
        }
    }

    @Test("Get User - Invalid UUID Returns Bad Request")
    func testGetUserInvalidUUID() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let user = try await userService.createUser(from: UserControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)

            try await app.testing().test(.GET, "/v1/users/invalid-uuid", headers: headers) { res in
                #expect(res.status == .badRequest)
            }
        }
    }

    @Test("Get User - Unauthorized Without Token")
    func testGetUserUnauthorized() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let user = try await userService.createUser(from: UserControllerTestHelper.sampleUser())

            try await app.testing().test(
                .GET, "/v1/users/\(user.id?.uuidString ?? "")"
            ) { res in
                #expect(res.status == .unauthorized)
            }
        }
    }

    // MARK: - Get Users Tests

    @Test("Get Users - Returns Paginated List")
    func testGetUsersSuccess() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let user1 = try await userService.createUser(
                from: User(firstName: "A", lastName: "One", email: "a1@test.com"))
            let user2 = try await userService.createUser(
                from: User(firstName: "B", lastName: "Two", email: "b2@test.com"))
            let user3 = try await userService.createUser(
                from: User(firstName: "C", lastName: "Three", email: "c3@test.com"))
            let headers = try await app.getTokenHeader(for: user1)

            try await app.testing().test(.GET, "/v1/users?page=1&per=2", headers: headers) { res in
                #expect(res.status == .ok)
                let body = try res.content.decode(Page<UserSummaryResponseDTO>.self)
                #expect(body.items.count == 2)
                #expect(body.metadata.total >= 3)
                #expect(body.metadata.page == 1)
                #expect(body.metadata.per == 2)
                #expect(body.items.contains { $0.id == user1.id })
                #expect(body.items.contains { $0.id == user2.id })
                #expect(!body.items.contains { $0.id == user3.id })
            }
        }
    }

    @Test("Get Users - Search")
    func testGetUsersSearch() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            _ = try await userService.createUser(
                from: User(firstName: "A", lastName: "One", email: "a1@test.com"))
            let user2 = try await userService.createUser(
                from: User(firstName: "B", lastName: "Two", email: "b2@test.com"))
            _ = try await userService.createUser(
                from: User(firstName: "C", lastName: "Three", email: "c3@test.com"))
            let headers = try await app.getTokenHeader(for: user2)

            let query = "two"

            try await app.testing().test(.GET, "/v1/users?page=1&per=2&search=\(query)", headers: headers) { res in
                #expect(res.status == .ok)
                let body = try res.content.decode(Page<UserSummaryResponseDTO>.self)
                #expect(body.items.count == 1)
                #expect(body.metadata.total == 1)
                #expect(body.metadata.page == 1)
                #expect(body.metadata.per == 2)
                #expect(body.items.contains { $0.id == user2.id })
            }
        }
    }

    @Test("Get Users - Unauthorized Without Token")
    func testGetUsersUnauthorized() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            _ = try await userService.createUser(
                from: User(firstName: "A", lastName: "One", email: "a1@test.com"))
            _ = try await userService.createUser(
                from: User(firstName: "B", lastName: "Two", email: "b2@test.com"))
            _ = try await userService.createUser(
                from: User(firstName: "C", lastName: "Three", email: "c3@test.com"))

            try await app.testing().test(.GET, "/v1/users") { res in
                #expect(res.status == .unauthorized)
            }
        }
    }

    // MARK: - Update User Tests

    @Test("Update User - Success (Own User)")
    func testUpdateUserSuccess() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let user = try await userService.createUser(from: UserControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)

            try await app.testing().test(
                .PUT,
                "/v1/users/\(user.id?.uuidString ?? "null")",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(UserControllerTestHelper.sampleUpdateDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .ok)
                    let body = try res.content.decode(UserDetailedResponseDTO.self)
                    #expect(body.id == user.id)
                    #expect(body.firstName == "Updated")
                    #expect(body.lastName == "Person")
                    #expect(body.email == "updated@test.com")
                }
            )
        }
    }

    @Test("Update User - Admin Can Update Other User")
    func testUpdateUserAsAdmin() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let user1 = try await userService.createUser(
                from: User(firstName: "User", lastName: "One", email: "user1@test.com"))

            let adminRole = UserRole(userID: user1.id!, role: .admin)
            try await user1.$roles.create(adminRole, on: app.db)

            let user2 = try await userService.createUser(
                from: User(firstName: "User", lastName: "Two", email: "user2@test.com"))
            let headers = try await app.getTokenHeader(for: user1)

            try await app.testing().test(
                .PUT,
                "/v1/users/\(user2.id?.uuidString ?? "null")",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(UserControllerTestHelper.sampleUpdateDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .ok)
                    let body = try res.content.decode(UserDetailedResponseDTO.self)
                    #expect(body.id == user2.id)
                    #expect(body.firstName == "Updated")
                }
            )
        }
    }

    @Test("Update User - Non-Admin Cannot Update Other User")
    func testUpdateUserNonAdminForbidden() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let user1 = try await userService.createUser(
                from: User(firstName: "User", lastName: "One", email: "user1@test.com"))
            let user2 = try await userService.createUser(
                from: User(firstName: "User", lastName: "Two", email: "user2@test.com"))
            let headers = try await app.getTokenHeader(for: user1)

            try await app.testing().test(
                .PUT,
                "/v1/users/\(user2.id?.uuidString ?? "null")",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(UserControllerTestHelper.sampleUpdateDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .forbidden)
                }
            )
        }
    }

    @Test("Update User - Invalid UUID Returns Bad Request")
    func testUpdateUserInvalidUUID() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let user = try await userService.createUser(from: UserControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)

            try await app.testing().test(
                .PUT,
                "/v1/users/invalid-uuid",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(UserControllerTestHelper.sampleUpdateDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .badRequest)
                }
            )
        }
    }

    @Test("Update User - Unauthorized Without Token")
    func testUpdateUserUnauthorized() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let user = try await userService.createUser(from: UserControllerTestHelper.sampleUser())

            try await app.testing().test(
                .PUT,
                "/v1/users/\(user.id?.uuidString ?? "")",
                beforeRequest: { req in
                    try req.content.encode(UserControllerTestHelper.sampleUpdateDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .unauthorized)
                }
            )
        }
    }

    @Test("Update User - Not Found Returns Not Found")
    func testUpdateUserNotFound() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let adminUser = try await userService.createUser(
                from: User(firstName: "Admin", lastName: "User", email: "admin@test.com"))
            let adminRole = UserRole(userID: adminUser.id!, role: .admin)
            try await adminRole.save(on: app.db)
            let headers = try await app.getTokenHeader(for: adminUser)

            try await app.testing().test(
                .PUT,
                "/v1/users/\(UUID().uuidString)",
                headers: headers,
                beforeRequest: { req in
                    try req.content.encode(UserControllerTestHelper.sampleUpdateDTO)
                },
                afterResponse: { res in
                    #expect(res.status == .notFound)
                }
            )
        }
    }

    // MARK: - Delete User Tests

    @Test("Delete User - Success (Own User)")
    func testDeleteUserSuccess() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let user = try await userService.createUser(from: UserControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)

            try await app.testing().test(
                .DELETE,
                "/v1/users/\(user.id?.uuidString ?? "null")",
                headers: headers
            ) { res in
                #expect(res.status == .noContent)
            }

            // Verify user was deleted
            let found = try await User.find(user.id, on: app.db)
            #expect(found == nil)
        }
    }

    @Test("Delete User - Non-Admin Cannot Delete Other User")
    func testDeleteUserNonAdminForbidden() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let user1 = try await userService.createUser(
                from: User(firstName: "User", lastName: "One", email: "user1@test.com"))
            let user2 = try await userService.createUser(
                from: User(firstName: "User", lastName: "Two", email: "user2@test.com"))
            let headers = try await app.getTokenHeader(for: user1)

            try await app.testing().test(
                .DELETE,
                "/v1/users/\(user2.id?.uuidString ?? "null")",
                headers: headers
            ) { res in
                #expect(res.status == .forbidden)
            }

            // Verify user2 was NOT deleted
            let found = try await User.find(user2.id, on: app.db)
            #expect(found != nil)
        }
    }

    @Test("Delete User - Admin Can Delete Other User")
    func testDeleteUserAdminNotForbidden() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let user1 = try await userService.createUser(
                from: User(firstName: "User", lastName: "One", email: "user1@test.com"))

            let adminRole = UserRole(userID: user1.id!, role: .admin)
            try await user1.$roles.create(adminRole, on: app.db)

            let user2 = try await userService.createUser(
                from: User(firstName: "User", lastName: "Two", email: "user2@test.com"))
            let headers = try await app.getTokenHeader(for: user1)

            try await app.testing().test(
                .DELETE,
                "/v1/users/\(user2.id?.uuidString ?? "null")",
                headers: headers
            ) { res in
                #expect(res.status == .noContent)
            }

            // Verify user2 was deleted
            let found = try await User.find(user2.id, on: app.db)
            #expect(found == nil)
        }
    }

    @Test("Delete User - Invalid UUID Returns Bad Request")
    func testDeleteUserInvalidUUID() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let user = try await userService.createUser(from: UserControllerTestHelper.sampleUser())
            let headers = try await app.getTokenHeader(for: user)

            try await app.testing().test(
                .DELETE, "/v1/users/invalid-uuid", headers: headers
            ) { res in
                #expect(res.status == .badRequest)
            }
        }
    }

    @Test("Delete User - Unauthorized Without Token")
    func testDeleteUserUnauthorized() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            _ = try await userService.createUser(from: UserControllerTestHelper.sampleUser())

            try await app.testing().test(.DELETE, "/v1/users/\(UUID().uuidString)") { res in
                #expect(res.status == .unauthorized)
            }
        }
    }
}
