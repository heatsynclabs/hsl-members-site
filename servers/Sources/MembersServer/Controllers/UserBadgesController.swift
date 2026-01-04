import Vapor
import VaporToOpenAPI

struct UserBadgesController: RouteCollection {
    private static let userIdParam = "userId"
    private static let missingUserIdError = Abort(.badRequest, reason: "Invalid or missing user ID parameter.")
    private static let badgeIdParam = "badgeId"
    private static let missingBadgeIdError = Abort(.badRequest, reason: "Invalid or missing badge ID parameter.")

    func boot(routes: any RoutesBuilder) throws {
        let userBadges = routes.grouped("users", ":\(Self.userIdParam)", "badges")

        userBadges.post(use: self.addBadge)
            .openAPI(
                summary: "Add a new user badge",
                description: "Add a badge for a user. The performing user must be an instructor for the given station",
                body: .type(UserBadgeRequestDTO.self),
                response: .type(UserBadgeDTO.self)
            )

        userBadges.delete(":\(Self.badgeIdParam)", use: self.deleteBadge)
            .openAPI(
                summary: "Delete a user badge",
                description: "Delete a badge for a user. The performing user must be an instructor for the given station",
                statusCode: .noContent
            )
    }

    func addBadge(req: Request) async throws -> UserBadgeDTO {
        let curUser = try req.auth.require(User.self)
        guard let badgeUser = req.parameters.get(Self.userIdParam, as: UUID.self) else {
            throw Self.missingUserIdError
        }

        try UserBadgeRequestDTO.validate(content: req)
        let body = try req.content.decode(UserBadgeRequestDTO.self)

        return try await req.userBadgeService.addBadge(body.badgeId, asUser: curUser, for: badgeUser)
    }

    func deleteBadge(req: Request) async throws -> HTTPStatus {
        let curUser = try req.auth.require(User.self)
        guard let badgeUser = req.parameters.get(Self.userIdParam, as: UUID.self) else {
            throw Self.missingUserIdError
        }
        guard let badgeId = req.parameters.get(Self.badgeIdParam, as: UUID.self) else {
            throw Self.missingBadgeIdError
        }

        try await req.userBadgeService.deleteBadge(badgeId, asUser: curUser, for: badgeUser)

        return .noContent
    }
}
