import Fluent
import Vapor

struct UserService {
    private let db: any Database
    private let logger: Logger

    init(db: any Database, logger: Logger) {
        self.db = db
        self.logger = logger
    }

    func getUser(for id: UUID) async throws -> User? {
        return try await getDetailedUser(id: id, on: db)
    }

    func getDetailedUser(id: UUID, curUserId: UUID) async throws -> UserDetailedResponseDTO? {
        let user = try await getDetailedUser(id: id, on: db)
        guard var user else {
            return nil
        }

        if curUserId != user.id {
            checkHiddenFields(user: &user)
        }

        return user.toDetailedDTO()
    }

    func getUsers(page: PageRequest) async throws -> Page<UserSummaryResponseDTO> {
        let users: Page<User> = try await User.query(on: db)
            .with(\.$membershipLevel) { $0.with(\.$membershipLevel) }
            .with(\.$orientation)
            .paginate(page)

        return users.map {
            var user = $0
            checkHiddenFields(user: &user)
            return user.toSummaryDTO()
        }
    }

    func updateUser(from dto: UserRequestDTO, for id: UUID) async throws -> UserDetailedResponseDTO
    {
        let user = dto.toUser()
        user.id = id
        return try await saveUser(user).toDetailedDTO()
    }

    func createUser(from user: User) async throws -> User {
        return try await saveUser(user)
    }

    private func saveUser(_ user: User) async throws -> User {
        return try await db.transaction { tDb in
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

    private func getDetailedUser(id: UUID, on db: any Database) async throws -> User? {
        return try await User.query(on: db)
            .with(\.$membershipLevel) { $0.with(\.$membershipLevel) }
            .with(\.$roles)
            .with(\.$orientation) { $0.with(\.$orientedBy) }
            .with(\.$instructorForStations)
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
