import Fluent
import struct Foundation.UUID
import struct Foundation.Date

final class DoorLog: Model, @unchecked Sendable {
    static let schema = "door_logs"

    @ID(key: .id)
    var id: UUID?

    // Can be null if a card number isn't used
    @Field(key: "card_number")
    var cardNumber: String?

    // Event key: access attempt codes ("G","R","D") or door events ("door_1_locked", ...)
    @Field(key: "key")
    var key: String

    // Numeric data: door status or card number depending on event
    @Field(key: "data")
    var data: Int

    // Not a foreign key (intentionally), store user id at time of access if available
    @Field(key: "user_id_when_accessed")
    var userIdWhenAccessed: UUID?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        cardNumber: String? = nil,
        key: String,
        data: Int,
        userIdWhenAccessed: UUID? = nil
    ) {
        self.id = id
        self.cardNumber = cardNumber
        self.key = key
        self.data = data
        self.userIdWhenAccessed = userIdWhenAccessed
    }
}
