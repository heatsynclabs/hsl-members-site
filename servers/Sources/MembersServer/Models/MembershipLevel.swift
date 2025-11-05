import Fluent
import struct Foundation.UUID
import struct Foundation.Date

final class MembershipLevel: Model, @unchecked Sendable {
    static let schema = "membership_levels"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "cost_in_cents")
    var costInCents: Int

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(id: UUID? = nil, name: String, costInCents: Int) {
        self.id = id
        self.name = name
        self.costInCents = costInCents
    }
}
