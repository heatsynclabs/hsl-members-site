import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class Card: Model, @unchecked Sendable {
    // Schema
    static let schema = "cards"

    static let fieldId = DbConstants.idField
    static let fieldCardNumber: FieldKey = "card_number"
    static let fieldCardPermissions: FieldKey = "card_permissions"
    static let fieldName = DbConstants.nameField
    static let fieldCreatedAt = DbConstants.createdAtField
    static let fieldUpdatedAt = DbConstants.updatedAtField
    static let fieldDeletedAt = DbConstants.deletedAtField

    private static let permissionsActive = 1
    private static let permissionsDisabled = 255

    // Model Fields
    @ID(key: .id)
    var id: UUID?

    @Field(key: fieldCardNumber)
    var cardNumber: String

    // 1 == Active, 255 == Disabled
    @Field(key: fieldCardPermissions)
    var cardPermissions: Int

    // Card label/name
    @Field(key: fieldName)
    var name: String?

    @Timestamp(key: fieldCreatedAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: fieldUpdatedAt, on: .update)
    var updatedAt: Date?

    @Timestamp(key: fieldDeletedAt, on: .delete)
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
