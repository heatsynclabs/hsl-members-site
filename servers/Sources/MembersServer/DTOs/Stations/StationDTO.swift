import Vapor

struct StationDTO: Content, Codable {
    var id: UUID
    var name: String
    var instructorCount: Int
    var createdAt: Date
    var updatedAt: Date
}
