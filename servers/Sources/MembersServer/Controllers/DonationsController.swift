import Vapor
import VaporToOpenAPI

struct DonationsController: RouteCollection {
    private static let donationIdParam = "id"
    private static let userIdParam = "userID"

    func boot(routes: any RoutesBuilder) throws {
        let jwtProtected = routes.grouped(UserAuthenticator(), User.guardMiddleware())
        let openApiProtected = jwtProtected.groupedOpenAPI(auth: .bearer())

        let donations = openApiProtected.grouped("donations")

        donations.get(use: self.getAllDonations)
            .openAPI(
                summary: "Get all donations",
                description: "Get a list of all donations (admin only)",
                response: .type([DonationResponseDTO].self)
            )

        donations.get(":\(Self.donationIdParam)", use: self.getDonation)
            .openAPI(
                summary: "Get a donation by id",
                description: "Get a specific donation by id (admin only)",
                response: .type(DonationResponseDTO.self)
            )

        donations.post(use: self.addDonation)
            .openAPI(
                summary: "Add a donation",
                description: "Add a new donation (admin only)",
                body: .type(DonationRequestDTO.self),
                response: .type(DonationResponseDTO.self)
            )

        donations.put(":\(Self.donationIdParam)", use: self.updateDonation)
            .openAPI(
                summary: "Update a donation",
                description: "Update an existing donation (admin only)",
                body: .type(DonationRequestDTO.self),
                response: .type(DonationResponseDTO.self)
            )

        donations.delete(":\(Self.donationIdParam)", use: self.deleteDonation)
            .openAPI(
                summary: "Delete a donation",
                description: "Delete a donation by id (admin only)",
                statusCode: .noContent
            )

        openApiProtected.get("users", ":\(Self.userIdParam)", "donations", use: self.getUserDonations)
            .openAPI(
                summary: "Get user's donations",
                description: "Get all donations for a specific user",
                response: .type([DonationResponseDTO].self)
            )
    }

    @Sendable
    func getAllDonations(req: Request) async throws -> [DonationResponseDTO] {
        let curUser = try req.auth.require(User.self)
        guard curUser.isAdmin else {
            throw UserError.userNotAdmin
        }

        return try await req.donationService.getAllDonations()
    }

    @Sendable
    func getDonation(req: Request) async throws -> DonationResponseDTO {
        let curUser = try req.auth.require(User.self)
        guard curUser.isAdmin else {
            throw UserError.userNotAdmin
        }

        guard let donationId = req.parameters.get(Self.donationIdParam, as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing donation ID parameter.")
        }

        let donation = try await req.donationService.getDonation(for: donationId)
        guard let donation else {
            throw DonationError.donationNotFound
        }

        return donation
    }

    @Sendable
    func addDonation(req: Request) async throws -> DonationResponseDTO {
        let curUser = try req.auth.require(User.self)
        guard curUser.isAdmin else {
            throw UserError.userNotAdmin
        }
        let id = try curUser.requireID()

        try DonationRequestDTO.validate(content: req)
        let dto = try req.content.decode(DonationRequestDTO.self)

        return try await req.donationService.addDonation(asUser: id, from: dto)
    }

    @Sendable
    func updateDonation(req: Request) async throws -> DonationResponseDTO {
        let curUser = try req.auth.require(User.self)
        guard curUser.isAdmin else {
            throw UserError.userNotAdmin
        }
        let id = try curUser.requireID()

        try DonationRequestDTO.validate(content: req)

        let dto = try req.content.decode(DonationRequestDTO.self)
        guard let donationId = req.parameters.get(Self.donationIdParam, as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing donation ID parameter.")
        }

        return try await req.donationService.updateDonation(asUser: id, from: dto, for: donationId)
    }

    @Sendable
    func deleteDonation(req: Request) async throws -> HTTPStatus {
        let curUser = try req.auth.require(User.self)
        guard curUser.isAdmin else {
            throw UserError.userNotAdmin
        }
        let id = try curUser.requireID()

        guard let donationId = req.parameters.get(Self.donationIdParam, as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing donation ID parameter.")
        }

        try await req.donationService.deleteDonation(asUser: id, id: donationId)
        return .noContent
    }

    @Sendable
    func getUserDonations(req: Request) async throws -> [DonationResponseDTO] {
        let curUser = try req.auth.require(User.self)
        let id = try curUser.requireID()

        guard let userId = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID parameter.")
        }

        guard curUser.isAdmin || userId == id else {
            throw UserError.userNotAdmin
        }

        return try await req.donationService.getDonations(for: userId)
    }
}
