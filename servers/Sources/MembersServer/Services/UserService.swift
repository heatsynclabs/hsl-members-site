import Fluent
import Vapor

struct UserService {
    private let db: any Database
    private let logger: Logger

    init(db: any Database, logger: Logger) {
        self.db = db
        self.logger = logger
    }

    func getUser(id: UUID, curUserId: UUID) async throws -> UserDetailedResponseDTO? {
        let user = try await User.query(on: db)
            .with(\.$membershipLevel) { $0.with(\.$membershipLevel) }
            .with(\.$roles)
            .with(\.$orientation) { $0.with(\.$orientedBy) }
            .with(\.$instructorForStations)
            .filter(\.$id == curUserId)
            .first()
        guard let user else {
            return nil
        }

        if user.hidden && curUserId != user.id {
            logger.warning(
                "User with id \(curUserId.uuidString) tried to access a hidden profile of user with id \(user.id?.uuidString ?? "null")"
            )
            throw UserError.userHidden
        }

        return user.toDetailedDTO()
    }

    func getUsers(page: PageRequest) async throws -> Page<UserSummaryResponseDTO> {
        let users: Page<User> = try await User.query(on: db)
            .with(\.$membershipLevel) { $0.with(\.$membershipLevel) }
            .with(\.$orientation)
            .filter(\.$hidden == false)
            .paginate(page)

        return users.map { $0.toSummaryDTO() }
    }
}

extension Request {
    var userService: UserService {
        return UserService(db: self.db, logger: self.logger)
    }
}
