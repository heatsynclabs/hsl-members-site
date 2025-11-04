import Fluent
import struct Foundation.UUID
import struct Foundation.Date

final class UserMembershipLevel: Model, @unchecked Sendable {
    static let schema = "user_membership_levels"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "membership_level_id")
    var membershipLevel: MembershipLevel

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(id: UUID? = nil, userID: UUID, membershipLevelID: UUID) {
        self.id = id
        self.$user.id = userID
        self.$membershipLevel.id = membershipLevelID
    }
}