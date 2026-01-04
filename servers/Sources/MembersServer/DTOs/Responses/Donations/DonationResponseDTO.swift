import struct Foundation.Date
import struct Foundation.UUID
import protocol Vapor.Content

struct DonationResponseDTO: Content {
    let id: UUID
    let userId: UUID?
    let amountInCents: Int
    let source: PaymentSource?
    let externalId: String?
    let purpose: String?
    let notes: String?
    let createdAt: Date
    let updatedAt: Date
}

extension Donation {
    func toResponseDTO() throws -> DonationResponseDTO {
        guard let id = self.id else {
            throw ServerError.unexpectedError(reason: "Donation id is missing")
        }
        return DonationResponseDTO(
            id: id,
            userId: $user.id,
            amountInCents: amountInCents,
            source: source,
            externalId: externalId,
            purpose: purpose,
            notes: notes,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
}
