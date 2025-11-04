import Vapor

struct CardDTO: Content, Codable {
    var id: UUID
    var cardNumber: String?
    var cardPermissions: Int?
    var userId: UUID?
    var userName: String?
    var name: String?
    var createdAt: Date
    var updatedAt: Date
}
