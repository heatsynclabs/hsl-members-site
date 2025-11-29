import Fluent
import SQLKit

struct AddBadgesMigration: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema(DbConstants.orientationsTable).delete()

        try await database.schema(DbConstants.badgesTable)
            .id()
            .field("name", .string, .required)
            .field(DbConstants.stationIdRelation, .uuid, .required, .references(DbConstants.stationsTable, DbConstants.idField, onDelete: .cascade))
            .field(DbConstants.createdAtField, .datetime, .required)
            .field(DbConstants.updatedAtField, .datetime, .required)
            .field(DbConstants.deletedAtField, .datetime)
            .create()

        try await database.schema(DbConstants.userBadgesTable)
            .id()
            .field(DbConstants.userIdRelation, .uuid, .required, .references(DbConstants.usersTable, DbConstants.idField, onDelete: .cascade))
            .field(DbConstants.badgesIdRelation, .uuid, .required, .references(DbConstants.badgesTable, DbConstants.idField, onDelete: .cascade))
            .field(DbConstants.createdAtField, .datetime, .required)
            .field(DbConstants.deletedAtField, .datetime)
            .create()
    }

    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema(DbConstants.userBadgesTable).delete()
        try await database.schema(DbConstants.badgesTable).delete()

        try await database.schema(DbConstants.orientationsTable)
            .id()
            .field("oriented_by_id", .uuid, .required, .references(DbConstants.usersTable, "id"))
            .field("oriented_user_id", .uuid, .required, .references(DbConstants.usersTable, "id"))
            .field(DbConstants.createdAtField, .datetime, .required)
            .field(DbConstants.updatedAtField, .datetime, .required)
            .field(DbConstants.deletedAtField, .datetime)
            .unique(on: "oriented_by_id", "oriented_user_id")
            .create()
    }
}
