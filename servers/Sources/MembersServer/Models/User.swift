import Fluent

import struct Foundation.Date
import struct Foundation.UUID
import protocol Vapor.Authenticatable

final class User: Model, Authenticatable, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String

    @Field(key: "first_name")
    var firstName: String?

    @Field(key: "last_name")
    var lastName: String?

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

    @Field(key: "hidden")
    var hidden: Bool

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

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    // Relations

    @Children(for: \.$user)
    var roles: [UserRole]

    @OptionalChild(for: \.$user)
    var membershipLevel: UserMembershipLevel?

    @OptionalChild(for: \.$orientedUser)
    var orientation: Orientation?

    @OptionalChild(for: \.$orientedBy)
    var orientedUsers: Orientation?

    @Children(for: \.$user)
    var instructorForStations: [Instructor]

    @Children(for: \.$user)
    var card: [UserCard]

    init() {}

    init(
        id: UUID,
        email: String,
        firstName: String? = nil,
        lastName: String? = nil,
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
        self.hidden = hidden
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
