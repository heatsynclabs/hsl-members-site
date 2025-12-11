import Fluent
import Vapor

struct UserService {
    private let database: any Database

    init(database: any Database) {
        self.database = database
    }

    func getUser(for id: UUID) async throws -> User? {
        return try await getDetailedUser(id: id, on: database)
    }

    func getDetailedUser(id: UUID, curUserId: UUID) async throws -> UserDetailedResponseDTO? {
        let user = try await getDetailedUser(id: id, on: database)
        guard var user else {
            return nil
        }

        if curUserId != user.id {
            checkHiddenFields(user: &user)
        }

        return try user.toDetailedDTO()
    }

    func getUsers(page: PageRequest, searchQuery: String?) async throws -> Page<UserSummaryResponseDTO> {
        var query = User.query(on: database)
            .with(\.$membershipLevel) { $0.with(\.$membershipLevel) }

        if let searchQuery, !searchQuery.isEmpty {
            let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            let searchTerms = trimmedQuery.split(separator: " ").map { String($0) }

            query = query.group(.or) { group in
                for term in searchTerms {
                    group.filter(\.$firstName ~~ term)
                    group.filter(\.$lastName ~~ term)
                }
                group.filter(\.$email ~~ trimmedQuery)
            }
        }

        let users = try await query.paginate(page)

        return try users.map {
            var user = $0
            checkHiddenFields(user: &user)
            return try user.toSummaryDTO()
        }
    }

    func updateUser(from dto: UserRequestDTO, for id: UUID) async throws -> UserDetailedResponseDTO {
        let user = try await getUser(for: id)
        guard let user else {
            throw UserError.userNotFound
        }

        dto.updateUser(user)
        try await user.save(on: database)
        return try user.toDetailedDTO()
    }

    func createUser(from user: User) async throws -> User {
        return try await database.transaction { tDb in
            try await user.save(on: tDb)
            guard let userId = user.id else {
                throw ServerError.unexpectedError(reason: "User ID is nil after save")
            }
            let createdUser = try await getDetailedUser(id: userId, on: tDb)
            guard let createdUser else {
                throw ServerError.unexpectedError(reason: "Created user returned nil")
            }

            return createdUser
        }
    }

    // Consider removal from auth provider (currently supabase)
    func deleteUser(id: UUID) async throws {
        try await User.query(on: database)
            .filter(\.$id == id)
            .delete()
    }

    private func getDetailedUser(id: UUID, on database: any Database) async throws -> User? {
        return try await User.query(on: database)
            .with(\.$membershipLevel) { $0.with(\.$membershipLevel) }
            .with(\.$badges) { $0.with(\.$badge) { $0.with(\.$station) } }
            .with(\.$roles)
            .with(\.$instructorForStations) { $0.with(\.$station) }
            .filter(\.$id == id)
            .first()
    }

    private func checkHiddenFields(user: inout User) {
        if !(user.emailVisible ?? true) {
            user.email = ""
        }
        if !(user.phoneVisible ?? true) {
            user.phone = nil
        }
    }
}
