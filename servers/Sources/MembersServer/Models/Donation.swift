import Fluent

import struct Foundation.Date
import struct Foundation.UUID

final class Donation: Model, @unchecked Sendable {
    static let schema = "donations"

    static let fieldId = DbConstants.idField
    static let fieldUserId = DbConstants.userIdRelation
    static let fieldAmountInCents = DbConstants.amountInCentsField
    static let fieldSource = DbConstants.sourceField
    static let fieldExternalId = DbConstants.externalIdField
    static let fieldPurpose = DbConstants.purposeField
    static let fieldNotes = DbConstants.notesField
    static let fieldCreatedAt = DbConstants.createdAtField
    static let fieldUpdatedAt = DbConstants.updatedAtField
    static let fieldDeletedAt = DbConstants.deletedAtField

    @ID(key: .id)
    var id: UUID?

    @OptionalParent(key: fieldUserId)
    var user: User?

    @Field(key: fieldAmountInCents)
    var amountInCents: Int

    @OptionalEnum(key: fieldSource)
    var source: PaymentSource?

    @Field(key: fieldExternalId)
    var externalId: String?

    @Field(key: fieldPurpose)
    var purpose: String?

    @Field(key: fieldNotes)
    var notes: String?

    @Timestamp(key: fieldCreatedAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: fieldUpdatedAt, on: .update)
    var updatedAt: Date?

    @Timestamp(key: fieldDeletedAt, on: .delete)
    var deletedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        userId: UUID? = nil,
        amountInCents: Int,
        source: PaymentSource? = nil,
        externalId: String? = nil,
        purpose: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        if let userId {
            self.$user.id = userId
        }
        self.amountInCents = amountInCents
        self.source = source
        self.externalId = externalId
        self.purpose = purpose
        self.notes = notes
    }
}
