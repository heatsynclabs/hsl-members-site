import Vapor

struct CardUserDTO: Content, Codable {
    var userId: UUID
    var userName: String
    var active: Bool
    var createdAt: Date
    var updatedAt: Date
}
