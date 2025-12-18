import Vapor

enum UserError: Error {
    case userNotAdmin
    case userNotFound
    case userIdMissing
}

extension UserError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .userNotAdmin:
            return .forbidden
        case .userNotFound:
            return .notFound
        case .userIdMissing:
            return .internalServerError
        }
    }

    var reason: String {
        switch self {
        case .userNotAdmin:
            return "User does not have the required permissions."
        case .userNotFound:
            return "The requested user was not found."
        case .userIdMissing:
            return "Internal server error."
        }
    }
}
