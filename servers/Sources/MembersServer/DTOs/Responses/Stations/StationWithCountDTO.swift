import Vapor

struct StationWithCountDTO: Content, Codable {
    var id: UUID
    var name: String
    var instructorCount: Int
    var createdAt: Date
    var updatedAt: Date
}
