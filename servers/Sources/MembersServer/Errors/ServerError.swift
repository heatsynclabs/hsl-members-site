import Vapor

enum ServerError: AbortError, DebuggableError {
    case unexpectedError(reason: String?)

    var status: HTTPResponseStatus {
        switch self {
        case .unexpectedError:
            return .internalServerError
        }
    }

    var reason: String {
        switch self {
        case .unexpectedError:
            return "An unexpected server error occurred."
        }
    }
}
