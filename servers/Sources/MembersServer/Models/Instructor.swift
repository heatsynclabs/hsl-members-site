import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class Instructor: Model, @unchecked Sendable {
    // Schema
    static let schema = "instructors"

    static let fieldId = DbConstants.idField
    static let fieldUserId = DbConstants.userIdRelation
    static let fieldStationId = DbConstants.stationIdRelation
    static let fieldCreatedAt = DbConstants.createdAtField
    static let fieldUpdatedAt = DbConstants.updatedAtField
    static let fieldDeletedAt = DbConstants.deletedAtField

    // Model Fields
    @ID(key: .id)
    var id: UUID?

    @Parent(key: fieldUserId)
    var user: User

    @Parent(key: fieldStationId)
    var station: Station

    @Timestamp(key: fieldCreatedAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: fieldUpdatedAt, on: .update)
    var updatedAt: Date?

    @Timestamp(key: fieldDeletedAt, on: .delete)
    var deletedAt: Date?

    init() {}

    init(id: UUID? = nil, userID: UUID, stationID: UUID) {
        self.id = id
        self.$user.id = userID
        self.$station.id = stationID
    }
}
