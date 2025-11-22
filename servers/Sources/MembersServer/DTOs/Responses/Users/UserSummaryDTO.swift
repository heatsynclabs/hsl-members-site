import Vapor

struct UserSummaryResponseDTO: Content, Codable {
    var id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var membershipLevel: MembershipLevelDTO?
    var hasOrientation: Bool
    var createdAt: Date
    var updatedAt: Date
}

extension User {
    func toSummaryDTO() -> UserSummaryResponseDTO {
        return UserSummaryResponseDTO(
            id: self.id!,
            firstName: self.firstName,
            lastName: self.lastName,
            email: self.email,
            membershipLevel: self.membershipLevel?.toDTO(),
            hasOrientation: self.orientation != nil,
            createdAt: self.createdAt ?? Date(),
            updatedAt: self.updatedAt ?? Date()
        )
    }
}
