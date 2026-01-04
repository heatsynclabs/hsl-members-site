import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class PaymentProfile: Model, @unchecked Sendable {
    static let schema = "payment_profiles"

    static let fieldId = DbConstants.idField
    static let fieldUserId = DbConstants.userIdRelation
    static let fieldSource = DbConstants.sourceField
    static let fieldExternalId = DbConstants.externalIdField
    static let fieldConnectedBy = DbConstants.connectedByField
    static let fieldCreatedAt = DbConstants.createdAtField
    static let fieldUpdatedAt = DbConstants.updatedAtField
    static let fieldDeletedAt = DbConstants.deletedAtField

    @ID(key: .id)
    var id: UUID?

    @Parent(key: fieldUserId)
    var user: User

    @Enum(key: fieldSource)
    var source: PaymentSource

    @Field(key: fieldExternalId)
    var externalId: String

    @Enum(key: fieldConnectedBy)
    var connectedBy: ConnectionMethod

    @Timestamp(key: fieldCreatedAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: fieldUpdatedAt, on: .update)
    var updatedAt: Date?

    @Timestamp(key: fieldDeletedAt, on: .delete)
    var deletedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        userId: UUID,
        source: PaymentSource,
        externalId: String,
        connectedBy: ConnectionMethod
    ) {
        self.id = id
        self.$user.id = userId
        self.source = source
        self.externalId = externalId
        self.connectedBy = connectedBy
    }
}

enum PaymentSource: String, Codable {
    case zeffy
    case zelle
    case paypal
    case cash
    case check
}

enum ConnectionMethod: String, Codable {
    case email
    case api
    case user
}
