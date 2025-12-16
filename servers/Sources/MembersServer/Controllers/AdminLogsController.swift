import Fluent
import Vapor
import VaporToOpenAPI

struct AdminLogsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let router = routes.grouped("admin-logs")

        router.get(use: self.getBadges)
            .openAPI(
                summary: "Get admin access logs",
                description: "Get a paginated list of admin access logs",
                query: .type(PageRequest.self),
                response: .type(Page<AdminLogDTO>.self)
            )
    }

    @Sendable
    func getBadges(req: Request) async throws -> Page<AdminLogDTO> {
        let curUser = try req.auth.require(User.self)

        if !curUser.isAdmin {
            req.logger.error(
                "Non admin user attempted to access admin logs",
                metadata: [
                    "userID": .string(curUser.id?.uuidString ?? "unknown")
                ]
            )
            throw UserError.userNotAdmin
        }

        return try await req.adminLogService.getLogs(page: req.pagination)
    }
}
