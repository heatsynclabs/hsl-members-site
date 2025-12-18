import Fluent
import Testing
import VaporTesting

@testable import MembersServer

@Suite("UserService Tests with DB", .serialized)
struct UserServiceTests {
    private static func sampleUser() -> User {
        .init(
            firstName: "User", lastName: "Service", email: "userservice@test.com")
    }

    @Test("Test Create User")
    func testCreateUser() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let createdUser = try await userService.createUser(from: Self.sampleUser())

            #expect(createdUser.id != nil)
            #expect(createdUser.firstName == createdUser.firstName)
            #expect(createdUser.lastName == createdUser.lastName)
            #expect(createdUser.email == createdUser.email)

            // Try to access relations, so you can ensure it is fully hydrated
            // Vapor will throw fatal errors if you try to access a relation that is not loaded
            _ = createdUser.membershipLevel
            _ = createdUser.membershipLevel?.membershipLevel
            _ = createdUser.instructorForStations
            _ = createdUser.badges
        }
    }

    @Test("Test Get User")
    func testGetUser() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let created = try await userService.createUser(from: Self.sampleUser())
            #expect(created.id != nil)

            let fetched = try await userService.getUser(for: created.id!)
            guard let fetched else {
                #expect(Bool(false), "Fetched user was nil")
                return
            }
            #expect(fetched.firstName == created.firstName)
            #expect(fetched.lastName == created.lastName)
            #expect(fetched.email == created.email)

            _ = fetched.membershipLevel
            _ = fetched.membershipLevel?.membershipLevel
            _ = fetched.instructorForStations
            _ = fetched.badges
        }
    }

    @Test("Test Update User")
    func testUpdateUser() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)
            let created = try await userService.createUser(from: Self.sampleUser())
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
            let userService = UserService(database: app.db)

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
            let userService = UserService(database: app.db)

            // create several users
            let users = [
                User(firstName: "A", lastName: "One", email: "a1@test.com"),
                User(firstName: "B", lastName: "Two", email: "b2@test.com"),
                User(firstName: "C", lastName: "Three", email: "c3@test.com")
            ]
            try await users.create(on: app.db)

            let pageRequest = PageRequest(page: 1, per: 2)
            let page = try await userService.getUsers(page: pageRequest, searchQuery: nil)

            #expect(page.items.count == 2)
            #expect(page.metadata.total >= 3)
        }
    }

    @Test("Test Get Users Search")
    func testGetUsersSearch() async throws {
        try await withApp { app in
            let userService = UserService(database: app.db)

            // create several users
            let users = [
                User(firstName: "A", lastName: "One", email: "a1@test.com"),
                User(firstName: "B", lastName: "Two", email: "b2@test.com"),
                User(firstName: "C", lastName: "Three", email: "c3@test.com")
            ]
            try await users.create(on: app.db)

            let userA = users[0]
            let userB = users[1]

            var searchQuery = "A"

            let pageRequest = PageRequest(page: 1, per: 2)
            let page = try await userService.getUsers(page: pageRequest, searchQuery: searchQuery)

            #expect(page.items.count == 1)
            #expect(page.metadata.total == 1)
            #expect(page.items.contains { $0.id == userA.id })

            searchQuery = "two"
            let page2 = try await userService.getUsers(page: pageRequest, searchQuery: searchQuery)
            #expect(page2.items.count == 1)
            #expect(page2.metadata.total == 1)
            #expect(page2.items.contains { $0.id == userB.id })

            searchQuery = "test.com"
            let allRequest = PageRequest(page: 1, per: 10)
            let page3 = try await userService.getUsers(page: allRequest, searchQuery: searchQuery)
            #expect(page3.items.count == 3)
            #expect(page3.metadata.total == 3)
            #expect(
                users.allSatisfy { user in
                    page3.items.contains { $0.id == user.id }
                })
        }
    }
}
