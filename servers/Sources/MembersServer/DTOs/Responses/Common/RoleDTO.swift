import Vapor

struct RoleDTO: Content, Codable {
    var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
}

extension UserRole {
    func toDTO() -> RoleDTO {
        return RoleDTO(
            id: self.id!,
            name: self.role.rawValue,
            createdAt: self.createdAt ?? Date(),
            updatedAt: self.updatedAt ?? Date()
        )
    }
}
