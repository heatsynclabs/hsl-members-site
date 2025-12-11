import Vapor

enum StationError: Error, Equatable {
    case stationNotFound
}

extension StationError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .stationNotFound:
            return .notFound
        }
    }

    var reason: String {
        switch self {
        case .stationNotFound:
            return "The station you requested could not be found."
        }
    }
}
