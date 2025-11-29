import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class UserBadge: Model, @unchecked Sendable {
    static let schema = DbConstants.userBadgesTable

    @ID(key: .id)
    var id: UUID?

    @Timestamp(key: DbConstants.createdAtField, on: .create)
    var createdAt: Date?

    @Timestamp(key: DbConstants.updatedAtField, on: .update)
    var updatedAt: Date?

    @Timestamp(key: DbConstants.deletedAtField, on: .delete)
    var deletedAt: Date?

    // Relations

    @Parent(key: DbConstants.userIdRelation)
    var user: User

    @Parent(key: DbConstants.badgesIdRelation)
    var badge: Badge
}
