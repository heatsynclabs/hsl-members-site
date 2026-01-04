import Vapor

enum PaymentProfileError: Error, Equatable {
    case paymentProfileNotFound
    case userNotFound
    case uniqueViolation
}

extension PaymentProfileError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .paymentProfileNotFound, .userNotFound:
            .notFound
        case .uniqueViolation:
            .conflict
        }
    }

    var reason: String {
        switch self {
        case .paymentProfileNotFound:
            "The payment profile you requested could not be found."
        case .userNotFound:
            "The user you specified could not be found."
        case .uniqueViolation:
            "A payment profile with this source and external ID already exists."
        }
    }
}
