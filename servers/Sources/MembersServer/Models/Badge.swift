import Fluent

import struct Foundation.Date

final class Badge: Model, @unchecked Sendable {
    static let schema = DbConstants.badgesTable

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Timestamp(key: DbConstants.createdAtField, on: .create)
    var createdAt: Date?

    @Timestamp(key: DbConstants.updatedAtField, on: .update)
    var updatedAt: Date?

    @Timestamp(key: DbConstants.deletedAtField, on: .delete)
    var deletedAt: Date?

    // Relations

    @Parent(key: DbConstants.stationIdRelation)
    var station: Station

    @Children(for: \.$badge)
    var users: [UserBadge]

    init() {}
}
