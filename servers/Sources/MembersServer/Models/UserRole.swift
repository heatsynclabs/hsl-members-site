import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class UserRole: Model, @unchecked Sendable {
    enum Role: String, Codable, CaseIterable {
        case admin = "admin"
        case accountant = "accountant"
        case cardHolder = "card_holder"
    }

    // Schema
    static let schema = "user_roles"

    static let fieldId = DbConstants.idField
    static let fieldUserId = DbConstants.userIdRelation
    static let fieldRole: FieldKey = "role"
    static let fieldCreatedAt = DbConstants.createdAtField
    static let fieldUpdatedAt = DbConstants.updatedAtField
    static let fieldDeletedAt = DbConstants.deletedAtField

    static let enumUserRole = "user_role"

    // Model Fields
    @ID(key: .id)
    var id: UUID?

    @Parent(key: fieldUserId)
    var user: User

    @Enum(key: fieldRole)
    var role: Role

    @Timestamp(key: fieldCreatedAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: fieldUpdatedAt, on: .update)
    var updatedAt: Date?

    @Timestamp(key: fieldDeletedAt, on: .delete)
    var deletedAt: Date?

    init() {}

    init(id: UUID? = nil, userID: UUID, role: Role) {
        self.id = id
        self.$user.id = userID
        self.role = role
    }
}
