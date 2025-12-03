import Fluent

import struct Foundation.Date
import struct Foundation.UUID
import protocol Vapor.Authenticatable

final class User: Model, Authenticatable, @unchecked Sendable {
    // Schema
    static let schema = "users"

    static let fieldId = DbConstants.idField
    static let fieldFirstName: FieldKey = "first_name"
    static let fieldLastName: FieldKey = "last_name"
    static let fieldEmail: FieldKey = "email"
    static let fieldWaiver: FieldKey = "waiver"
    static let fieldEmergencyName: FieldKey = "emergency_name"
    static let fieldEmergencyPhone: FieldKey = "emergency_phone"
    static let fieldEmergencyEmail: FieldKey = "emergency_email"
    static let fieldPaymentMethod: FieldKey = "payment_method"
    static let fieldPhone: FieldKey = "phone"
    static let fieldCurrentSkills: FieldKey = "current_skills"
    static let fieldDesiredSkills: FieldKey = "desired_skills"
    static let fieldHidden: FieldKey = "hidden"
    static let fieldMarketingSource: FieldKey = "marketing_source"
    static let fieldExitReason: FieldKey = "exit_reason"
    static let fieldTwitterUrl: FieldKey = "twitter_url"
    static let fieldFacebookUrl: FieldKey = "facebook_url"
    static let fieldGithubUrl: FieldKey = "github_url"
    static let fieldWebsiteUrl: FieldKey = "website_url"
    static let fieldEmailVisible: FieldKey = "email_visible"
    static let fieldPhoneVisible: FieldKey = "phone_visible"
    static let fieldPostalCode: FieldKey = "postal_code"
    static let fieldCreatedAt = DbConstants.createdAtField
    static let fieldUpdatedAt = DbConstants.updatedAtField
    static let fieldDeletedAt = DbConstants.deletedAtField

    // Model Fields
    @ID(key: .id)
    var id: UUID?

    @Field(key: fieldFirstName)
    var firstName: String

    @Field(key: fieldLastName)
    var lastName: String

    @Field(key: fieldEmail)
    var email: String

    @Field(key: fieldWaiver)
    var waiverSignedOn: Date?

    @Field(key: fieldEmergencyName)
    var emergencyName: String?

    @Field(key: fieldEmergencyPhone)
    var emergencyPhone: String?

    @Field(key: fieldEmergencyEmail)
    var emergencyEmail: String?

    @Field(key: fieldPaymentMethod)
    var paymentMethod: String?

    @Field(key: fieldPhone)
    var phone: String?

    @Field(key: fieldCurrentSkills)
    var currentSkills: String?

    @Field(key: fieldDesiredSkills)
    var desiredSkills: String?

    @Field(key: fieldMarketingSource)
    var marketingSource: String?

    @Field(key: fieldExitReason)
    var exitReason: String?

    @Field(key: fieldTwitterUrl)
    var twitterURL: String?

    @Field(key: fieldFacebookUrl)
    var facebookURL: String?

    @Field(key: fieldGithubUrl)
    var githubURL: String?

    @Field(key: fieldWebsiteUrl)
    var websiteURL: String?

    @Field(key: fieldEmailVisible)
    var emailVisible: Bool?

    @Field(key: fieldPhoneVisible)
    var phoneVisible: Bool?

    @Field(key: fieldPostalCode)
    var postalCode: String?

    @Timestamp(key: fieldCreatedAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: fieldUpdatedAt, on: .update)
    var updatedAt: Date?

    @Timestamp(key: fieldDeletedAt, on: .delete)
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

    @Children(for: \.$user)
    var badges: [UserBadge]

    // Computed Vars

    var fullName: String {
        return "\(self.firstName) \(self.lastName)"
    }

    var isAdmin: Bool {
        roles.contains { $0.role == .admin }
    }

    func hasRole(_ role: UserRole.Role) -> Bool {
        return roles.contains { $0.role == role }
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
