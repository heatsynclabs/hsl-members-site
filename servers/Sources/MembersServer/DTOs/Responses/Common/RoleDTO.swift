import Vapor

struct RoleDTO: Content, Codable {
    var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
}

extension UserRole {
    func toDTO() throws -> RoleDTO {
        guard let id else {
            throw ServerError.unexpectedError(reason: "Role id is missing")
        }

        return RoleDTO(
            id: id,
            name: self.role.rawValue,
            createdAt: self.createdAt ?? Date(),
            updatedAt: self.updatedAt ?? Date()
        )
    }
}
