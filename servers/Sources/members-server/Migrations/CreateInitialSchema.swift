import Fluent

// Initial schema migration from the old Open-Source-Access-Control-Web-Interface schema
// I tried to keep the same level of data to make the migration of existing data less painful
// while introducing some normalization improvements where it made sense
// Does not include payments or certifications, which will be added in later migrations
// I wanted to keep this one simpler and focused on core data structures first
struct CreateInitialSchema: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .field("id", .uuid, .identifier(auto: false))
            .field("first_name", .string, .required)
            .field("last_name", .string, .required)
            .field("email", .string, .required)

            // This is leftover field from the old users schema, I wasn't sure what to do with it
            // There is also a "contracts" table in the old schema that seems related
            // I'm keeping it here for now for reference, but we can probably better normalize it
            // once we understand the purpose better and if we need to log more signed docs other than waivers
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
            .field("hidden", .bool)
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

        try await database.schema("roles")
            .id()
            // Replaces the "admin" and "accountant" etc boolean fields on users
            // And makes it easier to add new roles in the future
            .field("name", .string, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "name")
            .create()

        try await database.schema("user_roles")
            .field("user_id", .uuid, .identifier(auto: false), .references("users", "id", onDelete: .cascade))
            .field("role_id", .uuid, .identifier(auto: false), .references("roles", "id", onDelete: .cascade))
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "user_id", "role_id")
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
            .field("user_id", .uuid, .identifier(auto: false), .references("users", "id", onDelete: .cascade))
            .field("membership_level_id", .uuid, .identifier(auto: false), .references("membership_levels", "id", onDelete: .cascade))
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "user_id", "membership_level_id")
            .create()

        // Replaces the old oriented_by_id and orientation date fields on users
        try await database.schema("orientations")
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
            .field("user_id", .uuid, .identifier(auto: false), .references("users", "id", onDelete: .cascade))
            .field("station_id", .uuid, .required, .references("stations", "id", onDelete: .cascade))
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "user_id", "station_id")  
            .create()

        try await database.schema("cards")
            .id()
            .field("card_number", .string)
            // Seems to only have two values and is flashed on the card I think
            // 1 == Active
            // 255 == Disabled
            .field("card_permissions", .int)
            // I set it null here because cards can still exist without being assigned to a user
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .setNull))
            // Card name (seems to be used for labeling cards in the system)
            .field("name", .string)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .create()
        
        try await database.schema("door_logs")
            .id()
            .field("card_number", .string, .identifier(auto: false), .references("cards", "card_number"))
            // This is a field that exists on the old schema and I can't figure out what it does yet
            // It looks like it might be a user id that gets set here when a door is accessed, but I'm not sure
            // Leaving it here now but we can probably remove  it later once we understand better
            .field("data", .int)
            // This isn't a foreign key because I don't want it to cascade/delete if the user is deleted
            // We already have the current user_id on the cards table relation if we need it anyways
            // I put this here because some admins at the lab are frustrated that the current system
            // will lose the user association if a card is reassigned to a new user.
            // For instance if someone tries to open the door with an unassigned card then tomorrow that card gets assigned to a new user,
            // the log entry will now show the new user instead of the original unassigned access attempt
            .field("user_id_when_accessed", .uuid)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("door_logs").delete()
        try await database.schema("cards").delete()
        try await database.schema("users").delete()
    }
}