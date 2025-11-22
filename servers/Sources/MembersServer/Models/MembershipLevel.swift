import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class MembershipLevel: Model, @unchecked Sendable {
    static let schema = DbConstants.membershipLevelsTable

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "cost_in_cents")
    var costInCents: Int

    @Timestamp(key: DbConstants.createdAtField, on: .create)
    var createdAt: Date?

    @Timestamp(key: DbConstants.updatedAtField, on: .update)
    var updatedAt: Date?

    @Timestamp(key: DbConstants.deletedAtField, on: .delete)
    var deletedAt: Date?

    init() {}

    init(id: UUID? = nil, name: String, costInCents: Int) {
        self.id = id
        self.name = name
        self.costInCents = costInCents
    }
}
