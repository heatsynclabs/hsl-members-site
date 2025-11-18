import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")

        users.get(use: self.getUsers)
        users.get(":userID", use: self.getUser)
    }

    @Sendable
    func getUser(req: Request) async throws -> UserDetailedResponseDTO {
        let curUser = try req.auth.require(User.self)

        let requestedUserId = req.parameters.get("userID", as: UUID.self)
        guard let userId = requestedUserId else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID parameter.")
        }

        let user = try await User.query(on: req.db)
            .with(\.$membershipLevel) { $0.with(\.$membershipLevel) }
            .with(\.$roles)
            .with(\.$orientation) { $0.with(\.$orientedBy) }
            .with(\.$instructorForStations)
            .filter(\.$id == userId)
            .first()
        guard let user else {
            throw Abort(.notFound, reason: "User with ID \(userId) not found.")
        }

        if user.hidden && curUser.id != user.id {
            req.logger.warning(
                "User with id \(curUser.id?.uuidString ?? "null") tried to access a hidden profile of user with id \(userId)"
            )
            throw Abort(.notFound, reason: "User with ID \(userId) not found.")
        }

        return user.toDetailedDTO()
    }

    @Sendable
    func getUsers(req: Request) async throws -> Page<UserSummaryResponseDTO> {
        let users: Page<User> = try await User.query(on: req.db)
            .with(\.$membershipLevel) { $0.with(\.$membershipLevel) }
            .with(\.$orientation)
            .filter(\.$hidden == false)
            .paginate(for: req)

        return users.map { $0.toSummaryDTO() }
    }
}
