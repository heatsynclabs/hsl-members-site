import Vapor

enum StationsError: Error, Equatable {
    enum UniqueField: String {
        case name
    }

    case uniqueViolation(field: UniqueField)
}

extension StationsError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .uniqueViolation:
            .conflict
        }
    }

    var reason: String {
        switch self {
        case .uniqueViolation(let field):
            "The value for \(field) you provided already exists, and must be unique."
        }
    }
}
