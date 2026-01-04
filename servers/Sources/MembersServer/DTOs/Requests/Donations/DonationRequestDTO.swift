import Vapor
import struct Foundation.UUID

struct DonationRequestDTO: Content {
    let userId: UUID?
    let amountInCents: Int
    let source: PaymentSource?
    let externalId: String?
    let purpose: String?
    let notes: String?
}

extension DonationRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("amountInCents", as: Int.self, is: .range(0...))
        validations.add("externalId", as: String.self, is: .count(1...500), required: false)
        validations.add("purpose", as: String.self, is: .count(1...1000), required: false)
        validations.add("notes", as: String.self, is: .count(1...5000), required: false)
    }
}

extension DonationRequestDTO {
    func toModel() -> Donation {
        return Donation(
            userId: userId,
            amountInCents: amountInCents,
            source: source,
            externalId: externalId,
            purpose: purpose,
            notes: notes
        )
    }

    func updateDonation(_ donation: Donation) {
        donation.amountInCents = amountInCents
        donation.source = source
        donation.externalId = externalId
        donation.purpose = purpose
        donation.notes = notes
    }
}
