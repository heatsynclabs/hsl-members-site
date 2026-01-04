import Fluent
import SQLKit

struct AddDonationsMigration: AsyncMigration {
    private static let idxPaymentProfilesUserId = "idx_payment_profiles_user_id"
    private static let idxDonationsUserId = "idx_donations_user_id"
    private static let idxDonationsCreatedAt = "idx_donations_created_at"

    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema(PaymentProfile.schema)
            .id()
            .field(PaymentProfile.fieldUserId, .uuid, .required, .references(User.schema, User.fieldId, onDelete: .cascade))
            .field(PaymentProfile.fieldSource, .string, .required)
            .field(PaymentProfile.fieldExternalId, .string, .required)
            .field(PaymentProfile.fieldConnectedBy, .string, .required)
            .field(PaymentProfile.fieldCreatedAt, .datetime, .required)
            .field(PaymentProfile.fieldUpdatedAt, .datetime, .required)
            .field(PaymentProfile.fieldDeletedAt, .datetime)
            .unique(on: PaymentProfile.fieldSource, PaymentProfile.fieldExternalId)
            .create()

        try await database.schema(Donation.schema)
            .id()
            .field(Donation.fieldUserId, .uuid, .references(User.schema, User.fieldId, onDelete: .setNull))
            .field(Donation.fieldAmountInCents, .int, .required)
            .field(Donation.fieldSource, .string)
            .field(Donation.fieldExternalId, .string)
            .field(Donation.fieldPurpose, .string)
            .field(Donation.fieldNotes, .string)
            .field(Donation.fieldCreatedAt, .datetime, .required)
            .field(Donation.fieldUpdatedAt, .datetime, .required)
            .field(Donation.fieldDeletedAt, .datetime)
            .create()

        guard let sqlDatabase = database as? any SQLDatabase else {
            fatalError("Attempting to use sql migration on non sql database")
        }

        try await sqlDatabase
            .create(index: Self.idxPaymentProfilesUserId)
            .on(PaymentProfile.schema)
            .column(PaymentProfile.fieldUserId.description)
            .run()

        try await sqlDatabase
            .create(index: Self.idxDonationsUserId)
            .on(Donation.schema)
            .column(Donation.fieldUserId.description)
            .run()

        try await sqlDatabase
            .create(index: Self.idxDonationsCreatedAt)
            .on(Donation.schema)
            .column(Donation.fieldCreatedAt.description)
            .run()
    }

    func revert(on database: any FluentKit.Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            fatalError("Attempting to use sql migration on non sql database")
        }

        try await sqlDatabase
            .drop(index: Self.idxDonationsCreatedAt)
            .run()

        try await sqlDatabase
            .drop(index: Self.idxDonationsUserId)
            .run()

        try await sqlDatabase
            .drop(index: Self.idxPaymentProfilesUserId)
            .run()

        try await database.schema(Donation.schema).delete()
        try await database.schema(PaymentProfile.schema).delete()
    }
}
