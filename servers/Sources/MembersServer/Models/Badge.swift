import Fluent

import struct Foundation.Date
import struct Foundation.URL

final class Badge: Model, @unchecked Sendable {
    // Schema
    static let schema = "badges"

    static let fieldId = DbConstants.idField
    static let fieldName = DbConstants.nameField
    static let fieldStationdId: FieldKey = DbConstants.stationIdRelation
    static let fieldDescription = DbConstants.descriptionField
    static let fieldImageUrl = DbConstants.imageUrlField
    static let fieldCreatedAt = DbConstants.createdAtField
    static let fieldUpdatedAt = DbConstants.updatedAtField
    static let fieldDeletedAt = DbConstants.deletedAtField

    // Model Fields
    @ID(key: .id)
    var id: UUID?

    @Field(key: fieldName)
    var name: String

    @Field(key: fieldDescription)
    var description: String

    @Field(key: fieldImageUrl)
    var imageUrlString: String?

    @Timestamp(key: fieldCreatedAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: fieldUpdatedAt, on: .update)
    var updatedAt: Date?

    @Timestamp(key: fieldDeletedAt, on: .delete)
    var deletedAt: Date?

    // Relations
    @Parent(key: fieldStationdId)
    var station: Station

    @Children(for: \.$badge)
    var users: [UserBadge]

    // Computer vars
    var imageURL: URL? {
        guard let imageUrlString else {
            return nil
        }
        return URL(string: imageUrlString)
    }

    init() {}

    init(
        id: UUID? = nil,
        name: String,
        description: String,
        imageUrlString: String?,
        stationId: UUID
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageUrlString = imageUrlString
        self.$station.id = stationId
    }
}
