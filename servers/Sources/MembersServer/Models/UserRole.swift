import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class UserRole: Model, @unchecked Sendable {
    enum Role: String, Codable, CaseIterable {
        case admin = "admin"
        case accountant = "accountant"
        case cardHolder = "card_holder"
    }

    static let schema = "user_roles"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Enum(key: "role")
    var role: Role

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(id: UUID? = nil, userID: UUID, role: Role) {
        self.id = id
        self.$user.id = userID
        self.role = role
    }
}
