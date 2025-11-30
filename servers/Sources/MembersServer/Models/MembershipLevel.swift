import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class MembershipLevel: Model, @unchecked Sendable {
    // Schema
    static let schema = "membership_levels"

    static let fieldId = DbConstants.idField
    static let fieldName = DbConstants.nameField
    static let fieldCostInCents: FieldKey = "cost_in_cents"
    static let fieldCreatedAt = DbConstants.createdAtField
    static let fieldUpdatedAt = DbConstants.updatedAtField
    static let fieldDeletedAt = DbConstants.deletedAtField

    // Model Fields
    @ID(key: .id)
    var id: UUID?

    @Field(key: fieldName)
    var name: String

    @Field(key: fieldCostInCents)
    var costInCents: Int

    @Timestamp(key: fieldCreatedAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: fieldUpdatedAt, on: .update)
    var updatedAt: Date?

    @Timestamp(key: fieldDeletedAt, on: .delete)
    var deletedAt: Date?

    init() {}

    init(id: UUID? = nil, name: String, costInCents: Int) {
        self.id = id
        self.name = name
        self.costInCents = costInCents
    }
}
