import Fluent
import Foundation

final class AdminLog: Model, @unchecked Sendable {
    static let schema = "admin_logs"

    static let fieldId: FieldKey = DbConstants.idField
    static let fieldUser: FieldKey = DbConstants.userIdRelation
    static let fieldLog: FieldKey = "log"
    static let fieldCreatedAt: FieldKey = DbConstants.createdAtField

    @ID(key: .id)
    var id: UUID?

    @Parent(key: fieldUser)
    var user: User

    @Field(key: fieldLog)
    var log: String

    @Timestamp(key: fieldCreatedAt, on: .create)
    var createdAt: Date?

    init() {}

    init(
        userId: UUID,
        log: String
    ) {
        self.$user.id = userId
        self.log = log
    }
}
