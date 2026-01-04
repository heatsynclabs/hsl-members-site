import Vapor
import VaporToOpenAPI

struct PaymentProfilesController: RouteCollection {
    private static let profileIdParam = "id"
    private static let userIdParam = "userID"

    func boot(routes: any RoutesBuilder) throws {
        let jwtProtected = routes.grouped(UserAuthenticator(), User.guardMiddleware())
        let openApiProtected = jwtProtected.groupedOpenAPI(auth: .bearer())

        openApiProtected.get("users", ":\(Self.userIdParam)", "payment-profiles", use: self.getUserPaymentProfiles)
            .openAPI(
                summary: "Get user's payment profiles",
                description: "Get all payment profiles for a specific user",
                response: .type([PaymentProfileResponseDTO].self)
            )

        let profiles = openApiProtected.grouped("payment-profiles")

        profiles.get(":\(Self.profileIdParam)", use: self.getPaymentProfile)
            .openAPI(
                summary: "Get a payment profile by id",
                description: "Get a specific payment profile by id (admin only)",
                response: .type(PaymentProfileResponseDTO.self)
            )

        profiles.post(use: self.addPaymentProfile)
            .openAPI(
                summary: "Add a payment profile",
                description: "Add a payment profile to a user (admin only)",
                body: .type(PaymentProfileRequestDTO.self),
                response: .type(PaymentProfileResponseDTO.self)
            )

        profiles.delete(":\(Self.profileIdParam)", use: self.deletePaymentProfile)
            .openAPI(
                summary: "Delete a payment profile",
                description: "Delete a payment profile by id (admin only)",
                statusCode: .noContent
            )
    }

    @Sendable
    func getUserPaymentProfiles(req: Request) async throws -> [PaymentProfileResponseDTO] {
        let curUser = try req.auth.require(User.self)
        let id = try curUser.requireID()

        guard let userId = req.parameters.get(Self.userIdParam, as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID parameter.")
        }

        guard curUser.isAdmin || userId == id else {
            throw UserError.userNotAdmin
        }

        return try await req.paymentProfileService.getPaymentProfiles(for: userId)
    }

    @Sendable
    func getPaymentProfile(req: Request) async throws -> PaymentProfileResponseDTO {
        let curUser = try req.auth.require(User.self)
        guard curUser.isAdmin else {
            throw UserError.userNotAdmin
        }

        guard let profileId = req.parameters.get(Self.profileIdParam, as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing payment profile ID parameter.")
        }

        let profile = try await req.paymentProfileService.getPaymentProfile(for: profileId)
        guard let profile else {
            throw PaymentProfileError.paymentProfileNotFound
        }

        return profile
    }

    @Sendable
    func addPaymentProfile(req: Request) async throws -> PaymentProfileResponseDTO {
        let curUser = try req.auth.require(User.self)
        guard curUser.isAdmin else {
            throw UserError.userNotAdmin
        }
        let id = try curUser.requireID()

        try PaymentProfileRequestDTO.validate(content: req)
        let dto = try req.content.decode(PaymentProfileRequestDTO.self)

        guard let userId = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID parameter.")
        }

        return try await req.paymentProfileService.addPaymentProfile(asUser: id, from: dto, to: userId)
    }

    @Sendable
    func deletePaymentProfile(req: Request) async throws -> HTTPStatus {
        let curUser = try req.auth.require(User.self)
        guard curUser.isAdmin else {
            throw UserError.userNotAdmin
        }
        let id = try curUser.requireID()

        guard let profileId = req.parameters.get(Self.profileIdParam, as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing payment profile ID parameter.")
        }

        try await req.paymentProfileService.deletePaymentProfile(asUser: id, id: profileId)
        return .noContent
    }
}
