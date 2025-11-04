import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class Orientation: Model, @unchecked Sendable {
    static let schema = "orientations"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "oriented_by_id")
    var orientedBy: User

    @Parent(key: "oriented_user_id")
    var orientedUser: User

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}
}
