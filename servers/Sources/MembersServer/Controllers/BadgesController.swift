import Fluent
import Vapor
import VaporToOpenAPI

struct BadgesController: RouteCollection {
    private static let badgeIdParam = "badgeId"
    private static let missingIdError = Abort(.badRequest, reason: "Invalid or missing badge ID parameter.")

    func boot(routes: any RoutesBuilder) throws {

    }

    @Sendable
    func getBadge(req: Request) async throws -> BadgeResponseDTO {
        let badgeId = req.parameters.get("badgeID", as: UUID.self)
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

        let badgeDTO = try req.content.decode(BadgeRequestDTO.self)
        return try await req.badgeService.addBadge(from: badgeDTO)
    }

    @Sendable
    func updateBadge(req: Request) async throws -> BadgeResponseDTO {
        let curUser = try req.auth.require(User.self)
        guard curUser.isAdmin else {
            throw UserError.userNotAdmin
        }

        let badgeDTO = try req.content.decode(BadgeRequestDTO.self)
        guard let badgeId = req.parameters.get(Self.badgeIdParam, as: UUID.self) else {
            throw Self.missingIdError
        }

        return try await req.badgeService.updateBadge(from: badgeDTO, for: badgeId)
    }

    @Sendable
    func deleteBadge(req: Request) async throws -> HTTPStatus {
        let curUser = try req.auth.require(User.self)
        guard curUser.isAdmin else {
            throw UserError.userNotAdmin
        }

        guard let badgeId = req.parameters.get(Self.badgeIdParam, as: UUID.self) else {
            throw Self.missingIdError
        }

        try await req.badgeService.deleteBadge(id: badgeId)
        return .noContent
    }
}
