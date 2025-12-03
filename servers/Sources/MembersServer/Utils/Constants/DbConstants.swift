import Fluent

enum DbConstants {
    // Common Fields
    static let idField: FieldKey = "id"
    static let createdAtField: FieldKey = "created_at"
    static let updatedAtField: FieldKey = "updated_at"
    static let deletedAtField: FieldKey = "deleted_at"
    static let imageUrlField: FieldKey = "image_url"
    static let nameField: FieldKey = "name"
    static let descriptionField: FieldKey = "description"

    static let userIdRelation: FieldKey = "user_id"
    static let stationIdRelation: FieldKey = "station_id"
    static let badgesIdRelation: FieldKey = "badge_id"
    static let membershipLevelIdRelation: FieldKey = "membership_level_id"

    // Removed Tables
    static let orientationsTable = "orientations"
}
