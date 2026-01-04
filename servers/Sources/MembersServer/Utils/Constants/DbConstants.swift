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

    // Payment Profile Fields
    static let sourceField: FieldKey = "source"
    static let externalIdField: FieldKey = "external_id"
    static let connectedByField: FieldKey = "connected_by"

    // Donation Fields
    static let amountInCentsField: FieldKey = "amount_in_cents"
    static let purposeField: FieldKey = "purpose"
    static let notesField: FieldKey = "notes"

    // Removed Tables
    static let orientationsTable = "orientations"
}
