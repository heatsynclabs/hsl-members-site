import Vapor

struct UserCardDTO: Content, Codable {
    var card: CardDTO
    var active: Bool
    var createdAt: Date
    var updatedAt: Date
}
