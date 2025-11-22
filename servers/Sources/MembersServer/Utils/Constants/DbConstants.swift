import Fluent

enum DbConstants {
    static let usersTable = "users"
    static let userRolesTable = "user_roles"
    static let membershipLevelsTable = "membership_levels"
    static let userMembershipLevelsTable = "user_membership_levels"
    static let orientationsTable = "orientations"
    static let stationsTable = "stations"
    static let instructorsTable = "instructors"
    static let cardsTable = "cards"
    static let userCardsTable = "user_cards"
    static let doorLogsTable = "door_logs"

    static let userRole = "user_role"

    static let createdAtField: FieldKey = "created_at"
    static let updatedAtField: FieldKey = "updated_at"
    static let deletedAtField: FieldKey = "deleted_at"
}
