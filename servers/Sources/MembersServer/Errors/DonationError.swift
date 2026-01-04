import Vapor

enum DonationError: Error, Equatable {
    case donationNotFound
    case userNotFound
}

extension DonationError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .donationNotFound, .userNotFound:
            .notFound
        }
    }

    var reason: String {
        switch self {
        case .donationNotFound:
            "The donation you requested could not be found."
        case .userNotFound:
            "The user you specified could not be found."
        }
    }
}
