import Vapor
import VaporToOpenAPI

struct BadgesController: RouteCollection {
    private static let badgeIdParam = "badgeId"
    private static let missingIdError = Abort(.badRequest, reason: "Invalid or missing badge ID parameter.")

    func boot(routes: any RoutesBuilder) throws {
        let badges = routes.grouped("badges")

        badges.get(use: self.getBadges)
            .openAPI(
                summary: "Get all badges",
                description: "Get a list of all badges",
                response: .type([BadgeResponseDTO].self)
            )

        badges.get(":\(Self.badgeIdParam)", use: self.getBadge)
            .openAPI(
                summary: "Get a badge by id",
                description: "Retrieves a badge by the provided id",
                response: .type(BadgeResponseDTO.self)
            )

        badges.post(use: self.addBadge)
            .openAPI(
                summary: "Add a new badge",
                description: "Add a new badge to the system (admin only)",
                body: .type(BadgeRequestDTO.self),
                response: .type(BadgeResponseDTO.self)
            )

        badges.put(":\(Self.badgeIdParam)", use: self.updateBadge)
            .openAPI(
                summary: "Update a badge",
                description: "Update an existing badge by id (admin only)",
                body: .type(BadgeRequestDTO.self),
                response: .type(BadgeResponseDTO.self)
            )

        badges.delete(":\(Self.badgeIdParam)", use: self.deleteBadge)
            .openAPI(
                summary: "Delete a badge",
                description: "Delete an existing badge by id (admin only)",
                statusCode: .noContent
            )
    }

    @Sendable
    func getBadge(req: Request) async throws -> BadgeResponseDTO {
        let badgeId = req.parameters.get(Self.badgeIdParam, as: UUID.self)
        guard let badgeId else {
            throw Abort(.badRequest, reason: "Invalid or missing badge ID parameter.")
        }

        let badge = try await req.badgeService.getBadge(for: badgeId)
        guard let badge else {
            throw Abort(.notFound, reason: "Badge with ID \(badgeId) not found.")
        }

        return badge
    }

    @Sendable
    func getBadges(req: Request) async throws -> [BadgeResponseDTO] {
        return try await req.badgeService.getAllBadges()
    }

    @Sendable
    func addBadge(req: Request) async throws -> BadgeResponseDTO {
        let curUser = try req.auth.require(User.self)
        guard curUser.isAdmin else {
            throw UserError.userNotAdmin
        }
        let id = try curUser.requireID()

        try BadgeRequestDTO.validate(content: req)
        let badgeDTO = try req.content.decode(BadgeRequestDTO.self)

        return try await req.badgeService.addBadge(asUser: id, from: badgeDTO)
    }

    @Sendable
    func updateBadge(req: Request) async throws -> BadgeResponseDTO {
        let curUser = try req.auth.require(User.self)
        guard curUser.isAdmin else {
            throw UserError.userNotAdmin
        }
        let id = try curUser.requireID()

        try BadgeRequestDTO.validate(content: req)

        let badgeDTO = try req.content.decode(BadgeRequestDTO.self)
        guard let badgeId = req.parameters.get(Self.badgeIdParam, as: UUID.self) else {
            throw Self.missingIdError
        }

        return try await req.badgeService.updateBadge(asUser: id, from: badgeDTO, for: badgeId)
    }

    @Sendable
    func deleteBadge(req: Request) async throws -> HTTPStatus {
        let curUser = try req.auth.require(User.self)
        guard curUser.isAdmin else {
            throw UserError.userNotAdmin
        }
        let id = try curUser.requireID()

        guard let badgeId = req.parameters.get(Self.badgeIdParam, as: UUID.self) else {
            throw Self.missingIdError
        }

        try await req.badgeService.deleteBadge(asUser: id, id: badgeId)
        return .noContent
    }
}
