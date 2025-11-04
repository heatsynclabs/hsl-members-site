import Vapor

struct StationBasicDTO: Content, Codable {
    var id: UUID
    var name: String
}
