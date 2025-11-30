import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class UserMembershipLevel: Model, @unchecked Sendable {
    // Schema
    static let schema = "user_membership_levels"

    static let fieldId = DbConstants.idField
    static let fieldUserId = DbConstants.userIdRelation
    static let fieldMembershipLevelId = DbConstants.membershipLevelIdRelation
    static let fieldCreatedAt = DbConstants.createdAtField
    static let fieldUpdatedAt = DbConstants.updatedAtField
    static let fieldDeletedAt = DbConstants.deletedAtField

    // Model Fields
    @ID(key: .id)
    var id: UUID?

    @Parent(key: fieldUserId)
    var user: User

    @Parent(key: fieldMembershipLevelId)
    var membershipLevel: MembershipLevel

    @Timestamp(key: fieldCreatedAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: fieldUpdatedAt, on: .update)
    var updatedAt: Date?

    @Timestamp(key: fieldDeletedAt, on: .delete)
    var deletedAt: Date?

    init() {}

    init(id: UUID? = nil, userID: UUID, membershipLevelID: UUID) {
        self.id = id
        self.$user.id = userID
        self.$membershipLevel.id = membershipLevelID
    }
}
