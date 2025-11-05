import Vapor

struct MembershipLevelDTO: Content, Codable {
    var id: UUID
    var name: String
    var costInCents: Int
    var createdAt: Date
    var updatedAt: Date
}
