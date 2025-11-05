import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class UserCard: Model, @unchecked Sendable {
    static let schema = "user_cards"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "card_id")
    var card: Card

    @Field(key: "active")
    var active: Bool

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        userId: UUID,
        cardId: UUID,
        active: Bool
    ) {
        self.id = id
        self.$user.id = userId
        self.$card.id = cardId
        self.active = active
    }
}
