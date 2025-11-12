import Vapor

struct MembershipLevelDTO: Content, Codable {
    var id: UUID
    var name: String
    var costInCents: Int
    var createdAt: Date
    var updatedAt: Date
}

extension UserMembershipLevel {
    func toDTO() -> MembershipLevelDTO {
        return MembershipLevelDTO(
            id: self.id!,
            name: self.membershipLevel.name,
            costInCents: self.membershipLevel.costInCents,
            createdAt: self.createdAt ?? Date(),
            updatedAt: self.updatedAt ?? Date()
        )
    }
}
