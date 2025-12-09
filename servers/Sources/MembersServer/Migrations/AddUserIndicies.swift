import Fluent
import SQLKit

struct AddUserIndicies: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            fatalError("Attempting to use sql migration on non sql database")
        }

        try await sqlDatabase
            .create(index: "idx_user_first_name")
            .on(User.schema)
            .column(User.fieldFirstName.description)
            .run()

        try await sqlDatabase
            .create(index: "idx_user_last_name")
            .on(User.schema)
            .column(User.fieldLastName.description)
            .run()

        try await sqlDatabase
            .create(index: "idx_user_name_full")
            .on(User.schema)
            .column(User.fieldFirstName.description)
            .column(User.fieldLastName.description)
            .run()

        try await sqlDatabase
            .create(index: "idx_user_cards_user_id")
            .on(UserCard.schema)
            .column(UserCard.fieldUserId.description)
            .run()

        try await sqlDatabase
            .create(index: "idx_user_cards_user_active")
            .on(UserCard.schema)
            .column(UserCard.fieldUserId.description)
            .column(UserCard.fieldActive.description)
            .run()
    }

    func revert(on database: any FluentKit.Database) async throws {

        guard let sqlDatabase = database as? any SQLDatabase else {
            fatalError("Attempting to use sql migration on non sql database")
        }

        try await sqlDatabase
            .drop(index: "idx_user_cards_user_active")
            .on(UserCard.schema)
            .run()

        try await sqlDatabase
            .drop(index: "idx_user_cards_user_id")
            .on(UserCard.schema)
            .run()

        try await sqlDatabase
            .drop(index: "idx_user_name_full")
            .on(User.schema)
            .run()

        try await sqlDatabase
            .drop(index: "idx_user_last_name")
            .on(User.schema)
            .run()

        try await sqlDatabase
            .drop(index: "idx_user_first_name")
            .on(User.schema)
            .run()
    }
}
