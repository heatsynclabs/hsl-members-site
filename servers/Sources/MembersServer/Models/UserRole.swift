import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class UserRole: Model, @unchecked Sendable {
    enum Role: String, Codable, CaseIterable {
        case admin = "admin"
        case accountant = "accountant"
        case cardHolder = "card_holder"
    }

    static let schema = DbConstants.userRolesTable

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Enum(key: "role")
    var role: Role

    @Timestamp(key: DbConstants.createdAtField, on: .create)
    var createdAt: Date?

    @Timestamp(key: DbConstants.updatedAtField, on: .update)
    var updatedAt: Date?

    init() {}

    init(id: UUID? = nil, userID: UUID, role: Role) {
        self.id = id
        self.$user.id = userID
        self.role = role
    }
}
