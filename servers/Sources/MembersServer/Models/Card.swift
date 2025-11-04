import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class Card: Model, @unchecked Sendable {
    static let schema = "cards"

    static let permissionsActive = 1
    static let permissionsDisabled = 255

    @ID(key: .id)
    var id: UUID?

    @Field(key: "card_number")
    var cardNumber: String?

    // 1 == Active, 255 == Disabled
    @Field(key: "card_permissions")
    var cardPermissions: Int?

    @OptionalParent(key: "user_id")
    var user: User?

    // Card label/name
    @Field(key: "name")
    var name: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        cardNumber: String? = nil,
        cardPermissions: Int? = nil,
        userId: UUID? = nil,
        name: String? = nil
    ) {
        self.id = id
        self.cardNumber = cardNumber
        self.cardPermissions = cardPermissions
        self.$user.id = userId
        self.name = name
    }
}
