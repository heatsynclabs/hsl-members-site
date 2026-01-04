import Vapor
import VaporToOpenAPI

struct ExternalDonationsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let donations = routes.grouped("donations")

        donations.post(use: self.createDonation)
            .openAPI(
                summary: "Create donation via API key",
                description: "Create a new donation using an API key in X-API-Key header",
                body: .type(DonationRequestDTO.self),
                response: .type(DonationResponseDTO.self)
            )
    }

    @Sendable
    func createDonation(req: Request) async throws -> DonationResponseDTO {
        guard let apiKeyHeader = req.headers["X-API-Key"].first else {
            throw Abort(.unauthorized, reason: "API key required")
        }

        let apiKey = try await req.donationService.verifyApiKey(apiKeyHeader)

        try DonationRequestDTO.validate(content: req)
        let dto = try req.content.decode(DonationRequestDTO.self)

        return try await req.donationService.addDonationWithApiKey(
            apiKey: apiKey,
            from: dto
        )
    }
}
