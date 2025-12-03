import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class Station: Model, @unchecked Sendable {
    // Schema
    static let schema = "stations"

    static let fieldId = DbConstants.idField
    static let fieldName = DbConstants.nameField
    static let fieldCreatedAt = DbConstants.createdAtField
    static let fieldUpdatedAt = DbConstants.updatedAtField
    static let fieldDeletedAt = DbConstants.deletedAtField

    // Model Fields
    @ID(key: .id)
    var id: UUID?

    @Field(key: fieldName)
    var name: String

    @Timestamp(key: fieldCreatedAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: fieldUpdatedAt, on: .update)
    var updatedAt: Date?

    @Timestamp(key: fieldDeletedAt, on: .delete)
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
