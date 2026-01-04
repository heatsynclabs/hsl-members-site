import Crypto
import Fluent

import struct Foundation.Data
import struct Foundation.Date
import struct Foundation.UUID

final class ApiKey: Model, @unchecked Sendable {
    static let schema = "api_keys"

    static let fieldId = DbConstants.idField
    static let fieldUserId = DbConstants.userIdRelation
    static let fieldName = DbConstants.nameField
    static let fieldKeyHash: FieldKey = "key_hash"
    static let fieldIsActive: FieldKey = "is_active"
    static let fieldExpiresAt: FieldKey = "expires_at"
    static let fieldCreatedBy: FieldKey = "created_by"
    static let fieldCreatedAt = DbConstants.createdAtField
    static let fieldUpdatedAt = DbConstants.updatedAtField
    static let fieldDeletedAt = DbConstants.deletedAtField

    @ID(key: .id)
    var id: UUID?

    @Parent(key: fieldUserId)
    var user: User

    @Field(key: fieldName)
    var name: String

    @Field(key: fieldKeyHash)
    var keyHash: String

    @Field(key: fieldIsActive)
    var isActive: Bool

    @OptionalField(key: fieldExpiresAt)
    var expiresAt: Date?

    @Field(key: fieldCreatedBy)
    var createdBy: UUID

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
        name: String,
        keyHash: String,
        isActive: Bool = true,
        expiresAt: Date? = nil,
        createdBy: UUID
    ) {
        self.id = id
        self.$user.id = userId
        self.name = name
        self.keyHash = keyHash
        self.isActive = isActive
        self.expiresAt = expiresAt
        self.createdBy = createdBy
    }
}

extension ApiKey {
    func verify(key: String) -> Bool {
        let data = Data(key.utf8)
        let hashedData = SHA256.hash(data: data)
        let hashedKeyString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashedKeyString == keyHash
    }
}
