import Vapor

struct OrientationRequestDTO: Content, Codable {
    var orientedById: UUID
}

extension OrientationRequestDTO {
    func toOrientation(for userId: UUID) -> Orientation {
        return Orientation(
            orientedById: self.orientedById,
            orientedUserId: userId
        )
    }
}
