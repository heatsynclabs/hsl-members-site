import Vapor

struct UserSummaryDTO: Content, Codable {
    var id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var hidden: Bool
    var membershipLevel: MembershipLevelDTO?
    var hasOrientation: Bool
    var createdAt: Date
}
