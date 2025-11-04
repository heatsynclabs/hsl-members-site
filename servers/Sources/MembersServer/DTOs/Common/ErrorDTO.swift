import Vapor

struct ErrorDTO: Content, Codable {
    var reason: String
}
