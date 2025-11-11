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
    var hidden: Bool
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

// extension User {
//     func toDetailedDTO(

//         ) -> UserDetailedDTO
//     {
//         return UserDetailedDTO(
//             id: self.id!,
//             firstName: self.firstName,
//             lastName: self.lastName,
//             email: self.email,
//             waiver: self.waiverSignedOn,
//             emergencyName: self.emergencyName,
//             emergencyPhone: self.emergencyPhone,
//             emergencyEmail: self.emergencyEmail,
//             paymentMethod: self.paymentMethod,
//             phone: self.phone,
//             currentSkills: self.currentSkills,
//             desiredSkills: self.desiredSkills,
//             hidden: self.hidden,
//             marketingSource: self.marketingSource,
//             exitReason: self.exitReason,
//             twitterUrl: self.twitterUrl,
//             facebookUrl: self.facebookUrl,
//             githubUrl: self.githubUrl,
//             websiteUrl: self.websiteUrl,
//             emailVisible: self.emailVisible,
//             phoneVisible: self.phoneVisible,
//             postalCode: self.postalCode,
//             membershipLevel: self.membershipLevel?.toDTO(),
//             roles: self.roles.map { $0.toDTO() },
//             orientation: self.orientation?.toDTO(),
//             instructorStations: self.instructorStations.map { $0.toBasicDTO() },
//             createdAt: self.createdAt ?? Date(),
//             updatedAt: self.updatedAt ?? Date()
//         )
//     }
// }
