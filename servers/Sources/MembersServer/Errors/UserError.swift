import Vapor

enum UserError: Error {
    case userNotAdmin
}

extension UserError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .userNotAdmin:
            return .forbidden
        }
    }

    var reason: String {
        switch self {
        case .userNotAdmin:
            return "User does not have the required permissions."
        }
    }
}
