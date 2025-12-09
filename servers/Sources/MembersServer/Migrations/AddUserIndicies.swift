import Fluent
import SQLKit

struct AddUserIndicies: AsyncMigration {
    private static let idxUserFirstName = "idx_user_first_name"
    private static let idxUserLastName = "idx_user_last_name"
    private static let idxUserNameFull = "idx_user_name_full"
    private static let idxUserCardsUserId = "idx_user_cards_user_id"
    private static let idxUserCardsUserActive = "idx_user_cards_user_active"

    func prepare(on database: any FluentKit.Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            fatalError("Attempting to use sql migration on non sql database")
        }

        try await sqlDatabase
            .create(index: Self.idxUserFirstName)
            .on(User.schema)
            .column(User.fieldFirstName.description)
            .run()

        try await sqlDatabase
            .create(index: Self.idxUserLastName)
            .on(User.schema)
            .column(User.fieldLastName.description)
            .run()

        try await sqlDatabase
            .create(index: Self.idxUserNameFull)
            .on(User.schema)
            .column(User.fieldFirstName.description)
            .column(User.fieldLastName.description)
            .run()

        try await sqlDatabase
            .create(index: Self.idxUserCardsUserId)
            .on(UserCard.schema)
            .column(UserCard.fieldUserId.description)
            .run()

        try await sqlDatabase
            .create(index: Self.idxUserCardsUserActive)
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
            .drop(index: Self.idxUserCardsUserActive)
            .run()

        try await sqlDatabase
            .drop(index: Self.idxUserCardsUserId)
            .run()

        try await sqlDatabase
            .drop(index: Self.idxUserNameFull)
            .run()

        try await sqlDatabase
            .drop(index: Self.idxUserLastName)
            .run()

        try await sqlDatabase
            .drop(index: Self.idxUserFirstName)
            .run()
    }
}
