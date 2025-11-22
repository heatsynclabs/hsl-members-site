import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class UserMembershipLevel: Model, @unchecked Sendable {
    static let schema = DbConstants.userMembershipLevelsTable

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "membership_level_id")
    var membershipLevel: MembershipLevel

    @Timestamp(key: DbConstants.createdAtField, on: .create)
    var createdAt: Date?

    @Timestamp(key: DbConstants.updatedAtField, on: .update)
    var updatedAt: Date?

    @Timestamp(key: DbConstants.deletedAtField, on: .delete)
    var deletedAt: Date?

    init() {}

    init(id: UUID? = nil, userID: UUID, membershipLevelID: UUID) {
        self.id = id
        self.$user.id = userID
        self.$membershipLevel.id = membershipLevelID
    }
}
