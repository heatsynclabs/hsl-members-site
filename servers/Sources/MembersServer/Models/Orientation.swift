import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class Orientation: Model, @unchecked Sendable {
    static let schema = DbConstants.orientationsTable

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "oriented_by_id")
    var orientedBy: User

    @Parent(key: "oriented_user_id")
    var orientedUser: User

    @Timestamp(key: DbConstants.createdAtField, on: .create)
    var createdAt: Date?

    @Timestamp(key: DbConstants.updatedAtField, on: .update)
    var updatedAt: Date?

    init() {}
}
