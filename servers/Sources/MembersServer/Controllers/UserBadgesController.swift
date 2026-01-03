import Vapor
import VaporToOpenAPI

struct UserBadgesController: RouteCollection {
    private static let userIdParam = "userId"
    private static let missingUserIdError = Abort(.badRequest, reason: "Invalid or missing user ID parameter.")
    private static let badgeIdParam = "badgeId"
    private static let missingBadgeIdError = Abort(.badRequest, reason: "Invalid or missing badge ID parameter.")

    func boot(routes: any RoutesBuilder) throws {
        let userBadges = routes.grouped("users", ":\(Self.userIdParam)", "badges")

    }

    
}
