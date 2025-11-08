import Fluent
import SQLKit

// Initial schema migration from the old Open-Source-Access-Control-Web-Interface schema
// I tried to keep the same level of data to make the migration of existing data less painful
// while introducing some normalization improvements where it made sense
// Does not include payments or certifications, which will be added in later migrations
// I wanted to keep this one simpler and focused on core data structures first
struct CreateInitialSchema: AsyncMigration {
    func prepare(on database: any Database) async throws {
        // For the users, I extracted a normalized what I could and kept core data fields
        // I didn't keep the password, last login etc fields since we most likely won't be using those
        // if we go with a different authentication system, but we can always add them back later if needed
        try await database.schema("users")
            .field("id", .uuid, .identifier(auto: false))
            .field("email", .string, .required)

            // Changing to not required because we will not have it during initial creation
            // If using a third party service like Supabase (we can decide how to handle this later)
            // For instance we can add it as metadata in the JWT and extract it during authentication (but this isn't enforceable 100%)
            // Or we can have a separate onboarding flow to collect it later
            .field("first_name", .string)
            .field("last_name", .string)

            // This is leftover field from the old users schema, I wasn't sure what to do with it
            // There is also a "contracts" table in the old schema that seems related
            // I'm keeping it here for now for reference, but we can probably better normalize it
            // once we understand the purpose better and if we need to log more signed docs other than waivers
            // (UPDATE) I talked to a few people at the lab and none of them seem to know what the contracts
            // table is for either. Once we get the prod database access we should look.
            .field("waiver", .datetime)

            .field("emergency_name", .string)
            .field("emergency_phone", .string)
            .field("emergency_email", .string)

            // We can probably normalize this better once we dig into payments later, or possibly keep it simple
            // and align with the old schema for now.
            .field("payment_method", .string)
            .field("phone", .string)
            .field("current_skills", .string)
            .field("desired_skills", .string)
            .field("hidden", .bool, .required, .sql(.default(false)))
            .field("marketing_source", .string)
            .field("exit_reason", .string)
            .field("twitter_url", .string)
            .field("facebook_url", .string)
            .field("github_url", .string)
            .field("website_url", .string)
            .field("email_visible", .bool)
            .field("phone_visible", .bool)
            .field("postal_code", .string)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "email")
            .create()

        // Replaces the old isAdmin and isAccountant fields on users
        // With easy extendablility to future roles
        let role = try await database.enum("user_role")
            .case("admin")
            .case("accountant")
            .case("card_holder")
            .create()

        try await database.schema("user_roles")
            .id()
            .field("user_id", .uuid, .references("users", "id", onDelete: .cascade), .required)
            .field("role", role, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "user_id", "role")
            .create()

        // Original schema had member_level as an odd range
        // 0 = "None"
        // 1 = "Unable"
        // 10..24 = "Volunteer"
        // 25..49 = "Associate ($25)"
        // 50..99 = "Basic ($50)"
        // 100..999 = "Plus ($100)"
        // It seems better to me to normalize it like this, and we can seed the levels later/convert existing data as needed
        try await database.schema("membership_levels")
            .id()
            .field("name", .string, .required)
            .field("cost_in_cents", .int, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "name")
            .create()

        // Just has simple association between users and membership levels for now
        // We may not to add more fields later depending on how we handle payment data
        try await database.schema("user_membership_levels")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field(
                "membership_level_id", .uuid, .required,
                .references("membership_levels", "id", onDelete: .cascade),
            )
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "user_id", "membership_level_id")
            .create()

        // Replaces the old oriented_by_id and orientation date fields on users
        try await database.schema("orientations")
            .id()
            .field("oriented_by_id", .uuid, .required, .references("users", "id"))
            .field("oriented_user_id", .uuid, .required, .references("users", "id"))
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "oriented_by_id", "oriented_user_id")
            .create()

        try await database.schema("stations")
            .id()
            .field("name", .string, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "name")
            .create()

        try await database.schema("instructors")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field(
                "station_id", .uuid, .required, .references("stations", "id", onDelete: .cascade)
            )
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "user_id", "station_id")
            .create()

        try await database.schema("cards")
            .id()
            .field("card_number", .string, .required)
            // Seems to only have two values and is flashed on the card I think
            // 1 == Active
            // 255 == Disabled
            .field("card_permissions", .int, .required)
            // Card name (seems to be used for labeling cards in the system)
            .field("name", .string)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "card_number")
            .create()

        // Keeps track of which cards are assigned to which users at what time
        // Designed to be an appendable log of card assignments, therefor we have an active flag
        // and no unique constraint on user_id/card_id
        try await database.schema("user_cards")
            .id()
            .field("card_id", .uuid, .required, .references("cards", "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("active", .bool, .required)
            .field("created_at", .datetime, .required)
            .create()

        try await database.schema("door_logs")
            .id()
            // Can be null if a card number isn't used (needs to be extracted from data)
            // such as for door events (locked/unlocked)
            // the old one didn't have a foreign key reference, but I thought it would be a nice touch
            .field("card_id", .uuid, .references("cards", "id"))
            // This is the key for what happened, which relates to access attempt or door status
            // The data changes based on the event type
            // For access attempt events: "G" = Granted, "R" = Read, "D" = Denied
            // For door events "door_1_locked" or "door_2_locked"
            .field("key", .string, .required)
            // This logs the status of the door when this event occured if a door event
            // 0 == Unlocked
            // 1 == Locked
            // If it's an access attempt event this is the card number that was used
            .field("data", .int, .required)
            .field("created_at", .datetime, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("door_logs").delete()
        try await database.schema("user_cards").delete()
        try await database.schema("cards").delete()
        try await database.schema("instructors").delete()
        try await database.schema("stations").delete()
        try await database.schema("orientations").delete()
        try await database.schema("user_membership_levels").delete()
        try await database.schema("membership_levels").delete()
        try await database.schema("user_roles").delete()
        try await database.schema("users").delete()

        try await database.enum("user_role").delete()
    }
}
