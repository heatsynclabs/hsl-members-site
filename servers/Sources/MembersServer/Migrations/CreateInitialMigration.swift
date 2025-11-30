// swiftlint:disable function_body_length
import Fluent
import SQLKit

// Initial schema migration from the old Open-Source-Access-Control-Web-Interface schema
// I tried to keep the same level of data to make the migration of existing data less painful
// while introducing some normalization improvements where it made sense
// Does not include payments or certifications, which will be added in later migrations
// I wanted to keep this one simpler and focused on core data structures first
struct CreateInitialMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        // For the users, I extracted a normalized what I could and kept core data fields
        // I didn't keep the password, last login etc fields since we most likely won't be using those
        // if we go with a different authentication system, but we can always add them back later if needed
        try await database.schema(User.schema)
            .field(User.fieldId, .uuid, .identifier(auto: false))
            .field(User.fieldFirstName, .string, .required)
            .field(User.fieldLastName, .string, .required)
            .field(User.fieldEmail, .string, .required)

            // This is leftover field from the old users schema, I wasn't sure what to do with it
            // There is also a "contracts" table in the old schema that seems related
            // I'm keeping it here for now for reference, but we can probably better normalize it
            // once we understand the purpose better and if we need to log more signed docs other than waivers
            // (UPDATE) I talked to a few people at the lab and none of them seem to know what the contracts
            // table is for either. Once we get the prod database access we should look.
            .field(User.fieldWaiver, .datetime)

            .field(User.fieldEmergencyName, .string)
            .field(User.fieldEmergencyPhone, .string)
            .field(User.fieldEmergencyEmail, .string)

            // We can probably normalize this better once we dig into payments later, or possibly keep it simple
            // and align with the old schema for now.
            .field(User.fieldPaymentMethod, .string)
            .field(User.fieldPhone, .string)
            .field(User.fieldCurrentSkills, .string)
            .field(User.fieldDesiredSkills, .string)
            .field(User.fieldHidden, .bool, .required, .sql(.default(false)))
            .field(User.fieldMarketingSource, .string)
            .field(User.fieldExitReason, .string)
            .field(User.fieldTwitterUrl, .string)
            .field(User.fieldFacebookUrl, .string)
            .field(User.fieldGithubUrl, .string)
            .field(User.fieldWebsiteUrl, .string)
            .field(User.fieldEmailVisible, .bool)
            .field(User.fieldPhoneVisible, .bool)
            .field(User.fieldPostalCode, .string)
            .field(User.fieldCreatedAt, .datetime, .required)
            .field(User.fieldUpdatedAt, .datetime, .required)
            .field(User.fieldDeletedAt, .datetime)
            .unique(on: User.fieldEmail)
            .create()

        // Replaces the old isAdmin and isAccountant fields on users
        // With easy extendablility to future roles
        let role = try await database.enum(UserRole.enumUserRole)
            .case(UserRole.Role.admin.rawValue)
            .case(UserRole.Role.accountant.rawValue)
            .case(UserRole.Role.cardHolder.rawValue)
            .create()

        try await database.schema(UserRole.schema)
            .id()
            .field(
                UserRole.fieldUserId, .uuid, .references(User.schema, User.fieldId, onDelete: .cascade),
                .required
            )
            .field(UserRole.fieldRole, role, .required)
            .field(UserRole.fieldCreatedAt, .datetime, .required)
            .field(UserRole.fieldUpdatedAt, .datetime, .required)
            .field(UserRole.fieldDeletedAt, .datetime)
            .unique(on: UserRole.fieldUserId, UserRole.fieldRole)
            .create()

        // Original schema had member_level as an odd range
        // 0 = "None"
        // 1 = "Unable"
        // 10..24 = "Volunteer"
        // 25..49 = "Associate ($25)"
        // 50..99 = "Basic ($50)"
        // 100..999 = "Plus ($100)"
        // It seems better to me to normalize it like this, and we can seed the levels later/convert
        // existing data as needed
        try await database.schema(MembershipLevel.schema)
            .id()
            .field(MembershipLevel.fieldName, .string, .required)
            .field(MembershipLevel.fieldCostInCents, .int, .required)
            .field(MembershipLevel.fieldCreatedAt, .datetime, .required)
            .field(MembershipLevel.fieldUpdatedAt, .datetime, .required)
            .field(MembershipLevel.fieldDeletedAt, .datetime)
            .unique(on: MembershipLevel.fieldName)
            .create()

        // Just has simple association between users and membership levels for now
        // We may not to add more fields later depending on how we handle payment data
        try await database.schema(UserMembershipLevel.schema)
            .id()
            .field(
                UserMembershipLevel.fieldUserId, .uuid, .required,
                .references(User.schema, User.fieldId, onDelete: .cascade)
            )
            .field(
                UserMembershipLevel.fieldMembershipLevelId, .uuid, .required,
                .references(MembershipLevel.schema, MembershipLevel.fieldId, onDelete: .cascade)
            )
            .field(UserMembershipLevel.fieldCreatedAt, .datetime, .required)
            .field(UserMembershipLevel.fieldUpdatedAt, .datetime, .required)
            .field(UserMembershipLevel.fieldDeletedAt, .datetime)
            .unique(on: UserMembershipLevel.fieldUserId, UserMembershipLevel.fieldMembershipLevelId)
            .create()

        // Replaces the old oriented_by_id and orientation date fields on users
        try await database.schema(DbConstants.orientationsTable)
            .id()
            .field("oriented_by_id", .uuid, .required, .references(User.schema, User.fieldId))
            .field("oriented_user_id", .uuid, .required, .references(User.schema, User.fieldId))
            .field(User.fieldCreatedAt, .datetime, .required)
            .field(User.fieldUpdatedAt, .datetime, .required)
            .field(User.fieldDeletedAt, .datetime)
            .unique(on: "oriented_by_id", "oriented_user_id")
            .create()

        try await database.schema(Station.schema)
            .id()
            .field(Station.fieldName, .string, .required)
            .field(Station.fieldCreatedAt, .datetime, .required)
            .field(Station.fieldUpdatedAt, .datetime, .required)
            .field(Station.fieldDeletedAt, .datetime)
            .unique(on: Station.fieldName)
            .create()

        try await database.schema(Instructor.schema)
            .id()
            .field(
                Instructor.fieldUserId, .uuid, .required,
                .references(User.schema, User.fieldId, onDelete: .cascade)
            )
            .field(
                Instructor.fieldStationId, .uuid, .required,
                .references(Station.schema, Station.fieldId, onDelete: .cascade)
            )
            .field(Instructor.fieldCreatedAt, .datetime, .required)
            .field(Instructor.fieldUpdatedAt, .datetime, .required)
            .field(Instructor.fieldDeletedAt, .datetime)
            .unique(on: Instructor.fieldUserId, Instructor.fieldStationId)
            .create()

        try await database.schema(Card.schema)
            .id()
            .field(Card.fieldCardNumber, .string, .required)
            // Seems to only have two values and is flashed on the card I think
            // 1 == Active
            // 255 == Disabled
            .field(Card.fieldCardPermissions, .int, .required)
            // Card name (seems to be used for labeling cards in the system)
            .field(Card.fieldName, .string)
            .field(Card.fieldCreatedAt, .datetime, .required)
            .field(Card.fieldUpdatedAt, .datetime, .required)
            .field(Card.fieldDeletedAt, .datetime)
            .unique(on: Card.fieldCardNumber)
            .create()

        // Keeps track of which cards are assigned to which users at what time
        // Designed to be an appendable log of card assignments, therefor we have an active flag
        // and no unique constraint on user_id/card_id
        try await database.schema(UserCard.schema)
            .id()
            .field(
                UserCard.fieldCardId, .uuid, .required,
                .references(Card.schema, Card.fieldId, onDelete: .cascade)
            )
            .field(
                UserCard.fieldUserId, .uuid, .required,
                .references(User.schema, User.fieldId, onDelete: .cascade)
            )
            .field(UserCard.fieldActive, .bool, .required)
            .field(UserCard.fieldCreatedAt, .datetime, .required)
            .create()

        try await database.schema(DoorLog.schema)
            .id()
            // Can be null if a card number isn't used (needs to be extracted from data)
            // such as for door events (locked/unlocked)
            // the old one didn't have a foreign key reference, but I thought it would be a nice touch
            .field(DoorLog.fieldCardId, .uuid, .references(Card.schema, Card.fieldId))
            // This is the key for what happened, which relates to access attempt or door status
            // The data changes based on the event type
            // For access attempt events: "G" = Granted, "R" = Read, "D" = Denied
            // For door events "door_1_locked" or "door_2_locked"
            .field(DoorLog.fieldKey, .string, .required)
            // This logs the status of the door when this event occured if a door event
            // 0 == Unlocked
            // 1 == Locked
            // If it's an access attempt event this is the card number that was used
            .field(DoorLog.fieldData, .int, .required)
            .field(DoorLog.fieldCreatedAt, .datetime, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(DoorLog.schema).delete()
        try await database.schema(UserCard.schema).delete()
        try await database.schema(Card.schema).delete()
        try await database.schema(Instructor.schema).delete()
        try await database.schema(Station.schema).delete()
        try await database.schema(DbConstants.orientationsTable).delete()
        try await database.schema(UserMembershipLevel.schema).delete()
        try await database.schema(MembershipLevel.schema).delete()
        try await database.schema(UserRole.schema).delete()
        try await database.schema(User.schema).delete()

        try await database.enum(UserRole.enumUserRole).delete()
    }
}
