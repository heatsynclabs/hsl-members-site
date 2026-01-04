import Vapor
import VaporToOpenAPI

struct ApiKeysController: RouteCollection {
    private static let apiKeyIdParam = "id"

    func boot(routes: any RoutesBuilder) throws {
        let jwtProtected = routes.grouped(UserAuthenticator(), User.guardMiddleware())
        let openApiProtected = jwtProtected.groupedOpenAPI(auth: .bearer())

        openApiProtected.get("users", ":userID", "api-keys", use: self.getUserApiKeys)
            .openAPI(
                summary: "Get user's API keys",
                description: "Get all API keys for a specific user (admin only)",
                response: .type([ApiKeyResponseDTO].self)
            )

        openApiProtected.post("users", ":userID", "api-keys", use: self.createApiKey)
            .openAPI(
                summary: "Create API key",
                description: "Create a new API key for a user (admin only)",
                body: .type(ApiKeyRequestDTO.self),
                response: .type(ApiKeyResponseDTO.self)
            )

        let apiKeys = openApiProtected.grouped("api-keys")

        apiKeys.delete(":\(Self.apiKeyIdParam)", use: self.deleteApiKey)
            .openAPI(
                summary: "Delete API key",
                description: "Delete an API key by id (admin only)",
                statusCode: .noContent
            )
    }

    @Sendable
    func getUserApiKeys(req: Request) async throws -> [ApiKeyResponseDTO] {
        let curUser = try req.auth.require(User.self)
        guard curUser.isAdmin else {
            throw UserError.userNotAdmin
        }

        guard let userId = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID parameter.")
        }

        return try await req.apiKeyService.getApiKeys(for: userId)
    }

    @Sendable
    func createApiKey(req: Request) async throws -> ApiKeyResponseDTO {
        let curUser = try req.auth.require(User.self)
        guard curUser.isAdmin else {
            throw UserError.userNotAdmin
        }
        let id = try curUser.requireID()

        try ApiKeyRequestDTO.validate(content: req)
        let dto = try req.content.decode(ApiKeyRequestDTO.self)

        guard let userId = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID parameter.")
        }

        return try await req.apiKeyService.createApiKey(
            asUser: id,
            for: userId,
            from: dto
        )
    }

    @Sendable
    func deleteApiKey(req: Request) async throws -> HTTPStatus {
        let curUser = try req.auth.require(User.self)
        guard curUser.isAdmin else {
            throw UserError.userNotAdmin
        }
        let id = try curUser.requireID()

        guard let apiKeyId = req.parameters.get(Self.apiKeyIdParam, as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing API key ID parameter.")
        }

        try await req.apiKeyService.deleteApiKey(asUser: id, id: apiKeyId)
        return .noContent
    }
}
