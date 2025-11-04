import Vapor

struct UserDetailedDTO: Content, Codable {
    var id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var waiver: Date?
    var emergencyName: String?
    var emergencyPhone: String?
    var emergencyEmail: String?
    var paymentMethod: String?
    var phone: String?
    var currentSkills: String?
    var desiredSkills: String?
    var hidden: Bool?
    var marketingSource: String?
    var exitReason: String?
    var twitterUrl: String?
    var facebookUrl: String?
    var githubUrl: String?
    var websiteUrl: String?
    var emailVisible: Bool?
    var phoneVisible: Bool?
    var postalCode: String?
    var membershipLevel: MembershipLevelDTO?
    var roles: [RoleDTO]
    var orientation: OrientationDTO?
    var instructorStations: [StationBasicDTO]
    var createdAt: Date
    var updatedAt: Date
}
