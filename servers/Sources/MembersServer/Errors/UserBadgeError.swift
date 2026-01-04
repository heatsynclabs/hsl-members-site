import Vapor

enum UserBadgeError: Error, Equatable {
    enum UniqueField: String {
        case badge
    }

    case uniqueViolation(field: UniqueField)
    case notInstructorForStation
}

extension UserBadgeError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .uniqueViolation:
            .conflict
        case .notInstructorForStation:
            .forbidden
        }
    }

    var reason: String {
        switch self {
        case .uniqueViolation(let field):
            "The value for \(field) you provided already exists, and must be unique."
        case .notInstructorForStation:
            "The user is not an instructor for this station."
        }
    }
}
