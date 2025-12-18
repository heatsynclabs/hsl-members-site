import Fluent
import SQLKit

struct AddAdminLogMigration: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema(AdminLog.schema)
            .id()
            .field(AdminLog.fieldUser, .uuid, .required, .references(User.schema, User.fieldId))
            .field(AdminLog.fieldLog, .string, .required)
            .field(AdminLog.fieldCreatedAt, .datetime, .required)
            .create()
    }

    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema(AdminLog.schema).delete()
    }
}
