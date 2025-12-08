import Vapor

enum BadgeError: Error, Equatable {
    enum UniqueField: String {
        case name
        case station
    }

    case uniqueViolation(field: UniqueField)
    case badgeNotFound
}

extension BadgeError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .uniqueViolation:
            .conflict
        case .badgeNotFound:
            .notFound
        }
    }

    var reason: String {
        switch self {
        case .uniqueViolation(let field):
            "The value for \(field) you provided already exists, and must be unique."
        case .badgeNotFound:
            "The badge you requested could not be found."
        }
    }
}
