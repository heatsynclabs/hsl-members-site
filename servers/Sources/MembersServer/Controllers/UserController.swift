import Fluent
import Vapor
import VaporToOpenAPI

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")

        users.get(use: self.getUsers)
            .openAPI(
                summary: "Get all users",
                description: "Get a paginated list of users, minus any hidden users",
                response: .type(Page<UserSummaryResponseDTO>.self)
            )

        users.get(":userID", use: self.getUser)
            .openAPI(
                summary: "Get a user by id",
                description: "Retrieves a user with detailed metadata by the provided id",
                response: .type(UserDetailedResponseDTO.self)
            )
    }

    @Sendable
    func getUser(req: Request) async throws -> UserDetailedResponseDTO {
        let curUser = try req.auth.require(User.self)
        guard let curUserId = curUser.id else {
            throw Abort(.unauthorized, reason: "Current user ID not found.")
        }

        let requestedUserId = req.parameters.get("userID", as: UUID.self)
        guard let userId = requestedUserId else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID parameter.")
        }

        do {
            let user = try await req.userService.getUser(id: userId, curUserId: curUserId)
            guard let user else {
                throw Abort(.notFound, reason: "User with ID \(userId) not found.")
            }
            return user
        } catch UserError.userHidden {
            throw Abort(.notFound, reason: "User with ID \(userId) not found.")
        }
    }

    @Sendable
    func getUsers(req: Request) async throws -> Page<UserSummaryResponseDTO> {
        return try await req.userService.getUsers(page: req.pagination)
    }
}
