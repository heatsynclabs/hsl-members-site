import Fluent
import SQLKit

struct AddBadgesMigration: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema(DbConstants.orientationsTable).delete()

        try await database.schema(Badge.schema)
            .id()
            .field(Badge.fieldName, .string, .required)
            .field(Badge.fieldStationdId, .uuid, .required, .references(DbConstants.stationsTable, DbConstants.idField, onDelete: .cascade))
            .field(Badge.fieldImageUrl, .string)
            .field(Badge.fieldCreatedAt, .datetime, .required)
            .field(Badge.fieldUpdatedAt, .datetime, .required)
            .field(Badge.fieldDeletedAt, .datetime)
            .unique(on: DbConstants.stationIdRelation)
            .create()

        try await database.schema(DbConstants.userBadgesTable)
            .id()
            .field(DbConstants.userIdRelation, .uuid, .required, .references(User.schema, Badge.fieldId, onDelete: .cascade))
            .field(DbConstants.badgesIdRelation, .uuid, .required, .references(Badge.schema, Badge.fieldId, onDelete: .cascade))
            .field(DbConstants.createdAtField, .datetime, .required)
            .field(DbConstants.updatedAtField, .datetime, .required)
            .field(DbConstants.deletedAtField, .datetime)
            .create()
    }

    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema(DbConstants.userBadgesTable).delete()
        try await database.schema(Badge.schema).delete()

        try await database.schema(DbConstants.orientationsTable)
            .id()
            .field("oriented_by_id", .uuid, .required, .references(DbConstants.usersTable, DbConstants.idField))
            .field("oriented_user_id", .uuid, .required, .references(DbConstants.usersTable, DbConstants.idField))
            .field(DbConstants.createdAtField, .datetime, .required)
            .field(DbConstants.updatedAtField, .datetime, .required)
            .field(DbConstants.deletedAtField, .datetime)
            .unique(on: "oriented_by_id", "oriented_user_id")
            .create()
    }
}
