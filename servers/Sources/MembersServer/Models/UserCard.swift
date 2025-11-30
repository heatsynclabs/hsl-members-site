import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class UserCard: Model, @unchecked Sendable {
    // Schema
    static let schema = "user_cards"

    static let fieldId = DbConstants.idField
    static let fieldUserId = DbConstants.userIdRelation
    static let fieldCardId: FieldKey = "card_id"
    static let fieldActive: FieldKey = "active"
    static let fieldCreatedAt = DbConstants.createdAtField

    // Model Fields
    @ID(key: .id)
    var id: UUID?

    @Parent(key: fieldUserId)
    var user: User

    @Parent(key: fieldCardId)
    var card: Card

    @Field(key: fieldActive)
    var active: Bool

    @Timestamp(key: fieldCreatedAt, on: .create)
    var createdAt: Date?

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
