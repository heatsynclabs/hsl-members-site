import Vapor

struct DoorLogDTO: Content, Codable {
    var id: UUID
    var cardId: UUID?
    var key: String
    var data: Int
    var createdAt: Date
}
