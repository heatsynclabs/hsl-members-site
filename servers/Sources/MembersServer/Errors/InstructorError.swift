import Vapor

enum InstructorError: Error, Equatable {
    enum UniqueField: String {
        case instructor
    }

    case uniqueViolation(field: UniqueField)
    case notFound
}

extension InstructorError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .uniqueViolation:
            .conflict
        case .notFound:
            .notFound
        }
    }

    var reason: String {
        switch self {
        case .uniqueViolation(let field):
            "The value for \(field) you provided already exists, and must be unique."
        case .notFound:
            "The instructor you requested could not be found."
        }
    }
}
