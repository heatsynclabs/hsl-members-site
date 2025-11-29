import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class Station: Model, @unchecked Sendable {
    static let schema = DbConstants.stationsTable

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

    @OptionalChild(for: \.$station)
    var badge: Badge?

    init() {}

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
