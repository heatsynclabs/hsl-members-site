import Vapor

struct UserDetailedResponseDTO: Content, Codable {
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
    var instructorStations: [StationBasicDTO]
    var badges: [UserBadgeDTO]
    var createdAt: Date
    var updatedAt: Date
}

extension User {
    func toDetailedDTO() throws -> UserDetailedResponseDTO {
        guard let id else {
            throw ServerError.unexpectedError(reason: "User id is missing")
        }

        return UserDetailedResponseDTO(
            id: id,
            firstName: self.firstName,
            lastName: self.lastName,
            email: self.email,
            waiver: self.waiverSignedOn,
            emergencyName: self.emergencyName,
            emergencyPhone: self.emergencyPhone,
            emergencyEmail: self.emergencyEmail,
            paymentMethod: self.paymentMethod,
            phone: self.phone,
            currentSkills: self.currentSkills,
            desiredSkills: self.desiredSkills,
            marketingSource: self.marketingSource,
            exitReason: self.exitReason,
            twitterUrl: self.twitterURL,
            facebookUrl: self.facebookURL,
            githubUrl: self.githubURL,
            websiteUrl: self.websiteURL,
            emailVisible: self.emailVisible,
            phoneVisible: self.phoneVisible,
            postalCode: self.postalCode,
            membershipLevel: try self.membershipLevel?.toDTO(),
            roles: try self.roles.map { try $0.toDTO() },
            instructorStations: try self.instructorForStations.map { try $0.station.toBasicDTO() },
            badges: try self.badges.map { try $0.toDTO() },
            createdAt: self.createdAt ?? Date(),
            updatedAt: self.updatedAt ?? Date()
        )
    }
}
