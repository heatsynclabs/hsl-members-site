import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class UserBadge: Model, @unchecked Sendable {
    // Schema
    static let schema = "user_badges"

    static let fieldId = DbConstants.idField
    static let fieldUserId = DbConstants.userIdRelation
    static let fieldBadgeId = DbConstants.badgesIdRelation
    static let fieldCreatedAt = DbConstants.createdAtField
    static let fieldUpdatedAt = DbConstants.updatedAtField
    static let fieldDeletedAt = DbConstants.deletedAtField

    // Model Fields
    @ID(key: .id)
    var id: UUID?

    @Timestamp(key: fieldCreatedAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: fieldUpdatedAt, on: .update)
    var updatedAt: Date?

    @Timestamp(key: fieldDeletedAt, on: .delete)
    var deletedAt: Date?

    // Relations
    @Parent(key: fieldUserId)
    var user: User

    @Parent(key: fieldBadgeId)
    var badge: Badge

    init() {}
}
