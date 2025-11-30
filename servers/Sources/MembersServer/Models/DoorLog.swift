import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class DoorLog: Model, @unchecked Sendable {
    // Schema
    static let schema = "door_logs"

    static let fieldId = DbConstants.idField
    static let fieldCardId: FieldKey = "card_id"
    static let fieldKey: FieldKey = "key"
    static let fieldData: FieldKey = "data"
    static let fieldCreatedAt = DbConstants.createdAtField

    // Model Fields
    @ID(key: .id)
    var id: UUID?

    // Can be null if a card number isn't used
    @OptionalParent(key: fieldCardId)
    var card: Card?

    // This is the key for what happened, which relates to access attempt or door status
    // The data changes based on the event type
    // For access attempt events: "G" = Granted, "R" = Read, "D" = Denied
    // For door events "door_1_locked" or "door_2_locked"
    @Field(key: fieldKey)
    var key: String

    // This logs the status of the door when this event occured if a door event
    // 0 == Unlocked
    // 1 == Locked
    // If it's an access attempt event this is the card number that was used
    @Field(key: fieldData)
    var data: Int

    @Timestamp(key: fieldCreatedAt, on: .create)
    var createdAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        cardId: UUID? = nil,
        key: String,
        data: Int,
    ) {
        self.id = id
        if let cardId: UUID = cardId {
            self.$card.id = cardId
        }
        self.key = key
        self.data = data
    }
}
