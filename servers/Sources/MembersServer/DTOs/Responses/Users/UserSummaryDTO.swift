import Vapor

struct UserSummaryResponseDTO: Content, Codable {
    var id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var membershipLevel: MembershipLevelDTO?
    var createdAt: Date
    var updatedAt: Date
}

extension User {
    func toSummaryDTO() throws -> UserSummaryResponseDTO {
        guard let id else {
            throw ServerError.unexpectedError(reason: "User id is missing")
        }

        return UserSummaryResponseDTO(
            id: id,
            firstName: self.firstName,
            lastName: self.lastName,
            email: self.email,
            membershipLevel: try self.membershipLevel?.toDTO(),
            createdAt: self.createdAt ?? Date(),
            updatedAt: self.updatedAt ?? Date()
        )
    }
}
