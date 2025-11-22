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

        users.post(":userID", use: self.updateUser)
            .openAPI(
                summary: "Update a current user"
            )
    }

    @Sendable
    func getUser(req: Request) async throws -> UserDetailedResponseDTO {
        let curUser = try req.auth.require(User.self)
        guard let curUserId = curUser.id else {
            throw Abort(.unauthorized, reason: "Current user ID not found.")
        }

        let userId = req.parameters.get("userID", as: UUID.self)
        guard let userId else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID parameter.")
        }

        let user = try await req.userService.getDetailedUser(id: userId, curUserId: curUserId)
        guard let user else {
            throw Abort(.notFound, reason: "User with ID \(userId) not found.")
        }
        return user
    }

    @Sendable
    func getUsers(req: Request) async throws -> Page<UserSummaryResponseDTO> {
        return try await req.userService.getUsers(page: req.pagination)
    }

    @Sendable
    func updateUser(req: Request) async throws -> UserDetailedResponseDTO {
        let curUser = try req.auth.require(User.self)
        try UserRequestDTO.validate(content: req)

        let userDTO = try req.content.decode(UserRequestDTO.self)
        let userId = req.parameters.get("userID", as: UUID.self)
        guard let userId else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID parameter.")
        }
        guard curUser.id == userId || !curUser.isAdmin else {
            throw UserError.userNotAdmin
        }

        return try await req.userService.updateUser(from: userDTO, for: userId)
    }
}
