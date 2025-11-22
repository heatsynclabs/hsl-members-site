import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class Instructor: Model, @unchecked Sendable {
    static let schema = DbConstants.instructorsTable

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "station_id")
    var station: Station

    @Timestamp(key: DbConstants.createdAtField, on: .create)
    var createdAt: Date?

    @Timestamp(key: DbConstants.updatedAtField, on: .update)
    var updatedAt: Date?

    @Timestamp(key: DbConstants.deletedAtField, on: .delete)
    var deletedAt: Date?

    init() {}

    init(id: UUID? = nil, userID: UUID, stationID: UUID) {
        self.id = id
        self.$user.id = userID
        self.$station.id = stationID
    }
}
