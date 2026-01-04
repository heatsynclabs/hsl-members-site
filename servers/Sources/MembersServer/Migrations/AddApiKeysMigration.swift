import Fluent
import SQLKit

struct AddApiKeysMigration: AsyncMigration {
    private static let idxApiKeysUserId = "idx_api_keys_user_id"
    private static let idxApiKeysHash = "idx_api_keys_key_hash"

    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema("api_keys")
            .id()
            .field(
                "user_id",
                .uuid,
                .required,
                .references("users", "id", onDelete: .cascade)
            )
            .field("name", .string, .required)
            .field("key_hash", .string, .required)
            .field("is_active", .bool, .required)
            .field("expires_at", .datetime)
            .field("created_by", .uuid, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .field("deleted_at", .datetime)
            .create()

        guard let sqlDatabase = database as? any SQLDatabase else {
            fatalError("Attempting to use sql migration on non sql database")
        }

        try await sqlDatabase
            .create(index: Self.idxApiKeysUserId)
            .on("api_keys")
            .column("user_id")
            .run()

        try await sqlDatabase
            .create(index: Self.idxApiKeysHash)
            .on("api_keys")
            .column("key_hash")
            .run()
    }

    func revert(on database: any FluentKit.Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            fatalError("Attempting to use sql migration on non sql database")
        }

        try await sqlDatabase
            .drop(index: Self.idxApiKeysHash)
            .run()

        try await sqlDatabase
            .drop(index: Self.idxApiKeysUserId)
            .run()

        try await database.schema("api_keys").delete()
    }
}
