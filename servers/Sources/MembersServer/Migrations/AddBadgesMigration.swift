import Fluent
import SQLKit

struct AddBadgesMigration: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema(DbConstants.orientationsTable).delete()

        try await database.schema(Badge.schema)
            .id()
            .field(Badge.fieldName, .string, .required)
            .field(Badge.fieldStationdId, .uuid, .required, .references(Station.schema, Station.fieldId, onDelete: .cascade))
            .field(Badge.fieldImageUrl, .string)
            .field(Badge.fieldCreatedAt, .datetime, .required)
            .field(Badge.fieldUpdatedAt, .datetime, .required)
            .field(Badge.fieldDeletedAt, .datetime)
            .unique(on: Badge.fieldStationdId)
            .create()

        try await database.schema(UserBadge.schema)
            .id()
            .field(UserBadge.fieldUserId, .uuid, .required, .references(User.schema, User.fieldId, onDelete: .cascade))
            .field(UserBadge.fieldBadgeId, .uuid, .required, .references(Badge.schema, Badge.fieldId, onDelete: .cascade))
            .field(UserBadge.fieldCreatedAt, .datetime, .required)
            .field(UserBadge.fieldUpdatedAt, .datetime, .required)
            .field(UserBadge.fieldDeletedAt, .datetime)
            .create()
    }

    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema(UserBadge.schema).delete()
        try await database.schema(Badge.schema).delete()

        try await database.schema(DbConstants.orientationsTable)
            .id()
            .field("oriented_by_id", .uuid, .required, .references(User.schema, User.fieldId))
            .field("oriented_user_id", .uuid, .required, .references(User.schema, User.fieldId))
            .field(User.fieldCreatedAt, .datetime, .required)
            .field(User.fieldUpdatedAt, .datetime, .required)
            .field(User.fieldDeletedAt, .datetime)
            .unique(on: "oriented_by_id", "oriented_user_id")
            .create()
    }
}
