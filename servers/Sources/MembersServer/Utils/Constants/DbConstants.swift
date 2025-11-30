import Fluent

enum DbConstants {
    static let usersTable = "users"
    static let userRolesTable = "user_roles"
    static let membershipLevelsTable = "membership_levels"
    static let userMembershipLevelsTable = "user_membership_levels"
    static let stationsTable = "stations"
    static let instructorsTable = "instructors"
    static let userBadgesTable = "user_badges"
    static let cardsTable = "cards"
    static let userCardsTable = "user_cards"
    static let doorLogsTable = "door_logs"

    static let userRole = "user_role"

    // Common Fields
    static let idField: FieldKey = "id"
    static let createdAtField: FieldKey = "created_at"
    static let updatedAtField: FieldKey = "updated_at"
    static let deletedAtField: FieldKey = "deleted_at"
    static let imageUrlField: FieldKey = "image_url"
    static let nameField: FieldKey = "name"

    static let userIdRelation: FieldKey = "user_id"
    static let stationIdRelation: FieldKey = "station_id"
    static let badgesIdRelation: FieldKey = "badge_id"
    static let membershipLevelIdRelation: FieldKey = "membership_level_id"

    // Removed Tables
    static let orientationsTable = "orientations"
}
