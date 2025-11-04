import Vapor

struct DoorLogDTO: Content, Codable {
    var id: UUID
    var cardNumber: String?
    var key: String
    var data: Int
    var userIdWhenAccessed: UUID?
    var userName: String?
    var createdAt: Date
    var updatedAt: Date
}
