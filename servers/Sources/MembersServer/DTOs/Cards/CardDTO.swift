import Vapor

struct CardDTO: Content, Codable {
    var id: UUID
    var cardNumber: String
    var cardPermissions: Int
    var name: String?
    var createdAt: Date
    var updatedAt: Date
}
