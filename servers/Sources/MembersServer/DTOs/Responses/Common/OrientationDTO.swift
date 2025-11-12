import Vapor

struct OrientationDTO: Content, Codable {
    var orientedById: UUID
    var orientedByName: String
    var createdAt: Date
    var updatedAt: Date
}

extension Orientation {
    func toDTO() -> OrientationDTO {
        return OrientationDTO(
            orientedById: self.orientedBy.id!,
            orientedByName: self.orientedBy.fullName,
            createdAt: self.createdAt ?? Date(),
            updatedAt: self.updatedAt ?? Date()
        )
    }
}
