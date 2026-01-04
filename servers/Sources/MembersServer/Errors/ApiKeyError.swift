import Vapor

enum ApiKeyError: Error {
    case invalidApiKey
    case apiKeyNotFound
    case apiKeyExpired
    case apiKeyInactive
    case userNotFound
}

extension ApiKeyError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .invalidApiKey, .apiKeyNotFound, .apiKeyExpired, .apiKeyInactive:
            .unauthorized
        case .userNotFound:
            .notFound
        }
    }

    var reason: String {
        switch self {
        case .invalidApiKey:
            "Invalid API key."
        case .apiKeyNotFound:
            "API key not found."
        case .apiKeyExpired:
            "API key has expired."
        case .apiKeyInactive:
            "API key is inactive."
        case .userNotFound:
            "User not found."
        }
    }
}
