import Vapor

struct UserOrientationDTO: Content, Codable {
    var id: UUID
    var orientedById: UUID
    var orientedByName: String
    var createdAt: Date
    var updatedAt: Date
}

extension Orientation {
    func toUserOrientationDTO() -> UserOrientationDTO {
        return UserOrientationDTO(
            id: self.id ?? UUID(),
            orientedById: self.orientedBy.id!,
            orientedByName: self.orientedBy.fullName,
            createdAt: self.createdAt ?? Date(),
            updatedAt: self.updatedAt ?? Date()
        )
    }
}
