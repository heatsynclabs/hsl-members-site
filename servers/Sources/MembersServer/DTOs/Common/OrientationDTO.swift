import Vapor

struct OrientationDTO: Content, Codable {
    var orientedById: UUID
    var orientedByName: String
    var createdAt: Date
    var updatedAt: Date
}
