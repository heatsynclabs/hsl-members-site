import Fluent

import struct Foundation.Date
import struct Foundation.UUID
import protocol Vapor.Authenticatable

final class User: Model, Authenticatable, @unchecked Sendable {
    static let schema = DbConstants.usersTable

    @ID(key: .id)
    var id: UUID?

    @Field(key: "first_name")
    var firstName: String

    @Field(key: "last_name")
    var lastName: String

    @Field(key: "email")
    var email: String

    @Field(key: "waiver")
    var waiverSignedOn: Date?

    @Field(key: "emergency_name")
    var emergencyName: String?

    @Field(key: "emergency_phone")
    var emergencyPhone: String?

    @Field(key: "emergency_email")
    var emergencyEmail: String?

    @Field(key: "payment_method")
    var paymentMethod: String?

    @Field(key: "phone")
    var phone: String?

    @Field(key: "current_skills")
    var currentSkills: String?

    @Field(key: "desired_skills")
    var desiredSkills: String?

    @Field(key: "marketing_source")
    var marketingSource: String?

    @Field(key: "exit_reason")
    var exitReason: String?

    @Field(key: "twitter_url")
    var twitterURL: String?

    @Field(key: "facebook_url")
    var facebookURL: String?

    @Field(key: "github_url")
    var githubURL: String?

    @Field(key: "website_url")
    var websiteURL: String?

    @Field(key: "email_visible")
    var emailVisible: Bool?

    @Field(key: "phone_visible")
    var phoneVisible: Bool?

    @Field(key: "postal_code")
    var postalCode: String?

    @Timestamp(key: DbConstants.createdAtField, on: .create)
    var createdAt: Date?

    @Timestamp(key: DbConstants.updatedAtField, on: .update)
    var updatedAt: Date?

    @Timestamp(key: DbConstants.deletedAtField, on: .delete)
    var deletedAt: Date?

    // Relations

    @Children(for: \.$user)
    var roles: [UserRole]

    @OptionalChild(for: \.$user)
    var membershipLevel: UserMembershipLevel?

    @Children(for: \.$user)
    var instructorForStations: [Instructor]

    @Children(for: \.$user)
    var card: [UserCard]

    // Computed Vars

    var fullName: String {
        return "\(self.firstName) \(self.lastName)"
    }

    var isAdmin: Bool {
        roles.contains { $0.role == .admin }
    }

    init() {}

    init(
        id: UUID? = nil,
        firstName: String,
        lastName: String,
        email: String,
        waiverSignedOn: Date? = nil,
        emergencyName: String? = nil,
        emergencyPhone: String? = nil,
        emergencyEmail: String? = nil,
        paymentMethod: String? = nil,
        phone: String? = nil,
        currentSkills: String? = nil,
        desiredSkills: String? = nil,
        hidden: Bool = false,
        marketingSource: String? = nil,
        exitReason: String? = nil,
        twitterURL: String? = nil,
        facebookURL: String? = nil,
        githubURL: String? = nil,
        websiteURL: String? = nil,
        emailVisible: Bool? = nil,
        phoneVisible: Bool? = nil,
        postalCode: String? = nil
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.waiverSignedOn = waiverSignedOn
        self.emergencyName = emergencyName
        self.emergencyPhone = emergencyPhone
        self.emergencyEmail = emergencyEmail
        self.paymentMethod = paymentMethod
        self.phone = phone
        self.currentSkills = currentSkills
        self.desiredSkills = desiredSkills
        self.marketingSource = marketingSource
        self.exitReason = exitReason
        self.twitterURL = twitterURL
        self.facebookURL = facebookURL
        self.githubURL = githubURL
        self.websiteURL = websiteURL
        self.emailVisible = emailVisible
        self.phoneVisible = phoneVisible
        self.postalCode = postalCode
    }
}
