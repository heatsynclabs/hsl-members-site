import Vapor

struct PaymentProfileRequestDTO: Content {
    let source: PaymentSource
    let externalId: String
    let connectedBy: ConnectionMethod
}

extension PaymentProfileRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("externalId", as: String.self, is: .count(1...500))
    }
}

extension PaymentProfileRequestDTO {
    func toModel(userId: UUID) -> PaymentProfile {
        return PaymentProfile(
            userId: userId,
            source: source,
            externalId: externalId,
            connectedBy: connectedBy
        )
    }
}
