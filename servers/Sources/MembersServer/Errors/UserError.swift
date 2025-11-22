import Vapor

enum UserError: Error {
    case userNotAdmin
    case userNotFound
}

extension UserError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .userNotAdmin:
            return .forbidden
        case .userNotFound:
            return .notFound
        }
    }

    var reason: String {
        switch self {
        case .userNotAdmin:
            return "User does not have the required permissions."
        case .userNotFound:
            return "The requested user was not found."
        }
    }
}
