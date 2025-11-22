import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class Card: Model, @unchecked Sendable {
    static let schema = DbConstants.cardsTable

    private static let permissionsActive = 1
    private static let permissionsDisabled = 255

    @ID(key: .id)
    var id: UUID?

    @Field(key: "card_number")
    var cardNumber: String

    // 1 == Active, 255 == Disabled
    @Field(key: "card_permissions")
    var cardPermissions: Int

    // Card label/name
    @Field(key: "name")
    var name: String?

    @Timestamp(key: DbConstants.createdAtField, on: .create)
    var createdAt: Date?

    @Timestamp(key: DbConstants.updatedAtField, on: .update)
    var updatedAt: Date?

    @Timestamp(key: DbConstants.deletedAtField, on: .delete)
    var deletedAt: Date?

    var isActive: Bool { cardPermissions == Card.permissionsActive }

    init() {}

    init(
        id: UUID? = nil,
        cardNumber: String,
        cardPermissions: Int,
        name: String? = nil
    ) {
        self.id = id
        self.cardNumber = cardNumber
        self.cardPermissions = cardPermissions
        self.name = name
    }
}
