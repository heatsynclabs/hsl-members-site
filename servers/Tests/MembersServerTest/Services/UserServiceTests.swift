import Fluent
import Testing
import VaporTesting

@testable import MembersServer

@Suite("UserService Tests with DB", .serialized)
struct UserServiceTests {
    let sampleUser: User = .init(firstName: "Testy", lastName: "Testerson", email: "test@test.com")

    @Test("Test Create User")
    func testCreateUser() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let createdUser = try await userService.createUser(from: sampleUser)

            #expect(createdUser.id != nil)
            #expect(createdUser.firstName == sampleUser.firstName)
            #expect(createdUser.lastName == sampleUser.lastName)
            #expect(createdUser.email == sampleUser.email)

            // Try to access relations, so you can ensure it is fully hydrated
            // Vapor will throw fatal errors if you try to access a relation that is not loaded
            _ = createdUser.membershipLevel
            _ = createdUser.membershipLevel?.membershipLevel
            _ = createdUser.orientation
            _ = createdUser.orientation?.orientedBy
            _ = createdUser.orientedUsers
            _ = createdUser.instructorForStations
        }
    }

    @Test("Test Get User")
    func testGetUser() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let created = try await userService.createUser(from: sampleUser)
            #expect(created.id != nil)

            let fetched = try await userService.getUser(for: created.id!)
            #expect(fetched != nil)
            #expect(fetched?.firstName == sampleUser.firstName)
            #expect(fetched?.lastName == sampleUser.lastName)
            #expect(fetched?.email == sampleUser.email)
        }
    }

    @Test("Test Update User")
    func testUpdateUser() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let created = try await userService.createUser(from: sampleUser)
            #expect(created.id != nil)

            let updateDTO = UserRequestDTO(
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

            let updated = try await userService.updateUser(from: updateDTO, for: created.id!)
            #expect(updated.firstName == "Updated")
            #expect(updated.lastName == "Person")
            #expect(updated.email == "updated@test.com")
        }
    }

    @Test("Update Non-Existent User Throws Error")
    func testUpdateNonExistentUser() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)

            await #expect(throws: UserError.userNotFound) {
                let updateDTO = UserRequestDTO(
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

                _ = try await userService.updateUser(from: updateDTO, for: UUID())
            }
        }
    }

    @Test("Test Get Users Pagination")
    func testGetUsers() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)

            // create several users
            let users = [
                User(firstName: "A", lastName: "One", email: "a1@test.com"),
                User(firstName: "B", lastName: "Two", email: "b2@test.com"),
                User(firstName: "C", lastName: "Three", email: "c3@test.com"),
            ]
            try await users.create(on: app.db)

            let pageRequest = PageRequest(page: 1, per: 2)
            let page = try await userService.getUsers(page: pageRequest)

            #expect(page.items.count == 2)
            #expect(page.metadata.total >= 3)
        }
    }

    @Test("Test Delete User")
    func testDeleteUser() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db, logger: app.logger)
            let created = try await userService.createUser(from: sampleUser)
            #expect(created.id != nil)

            try await userService.deleteUser(id: created.id!)

            let found = try await User.find(created.id, on: app.db)
            #expect(found == nil)
        }
    }
}
