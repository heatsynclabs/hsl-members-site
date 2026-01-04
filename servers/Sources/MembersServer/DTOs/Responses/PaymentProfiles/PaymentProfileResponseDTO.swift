import struct Foundation.Date
import struct Foundation.UUID
import protocol Vapor.Content

struct PaymentProfileResponseDTO: Content {
    let id: UUID
    let userId: UUID
    let source: PaymentSource
    let externalId: String
    let connectedBy: ConnectionMethod
    let createdAt: Date
    let updatedAt: Date
}

extension PaymentProfile {
    func toResponseDTO() throws -> PaymentProfileResponseDTO {
        guard let id = self.id else {
            throw ServerError.unexpectedError(reason: "PaymentProfile id is missing")
        }
        return PaymentProfileResponseDTO(
            id: id,
            userId: $user.id,
            source: source,
            externalId: externalId,
            connectedBy: connectedBy,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
}
