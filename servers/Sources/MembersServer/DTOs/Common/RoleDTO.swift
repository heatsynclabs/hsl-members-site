import Vapor

struct RoleDTO: Content, Codable {
    var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
}
