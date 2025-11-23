import Vapor

struct OrientationRequestDTO: Content, Codable {
    var orientedById: UUID
}

// extension OrientationRequestDTO {
//     func toOrientation() -> Orientation {
//         return Orientation(
//             orientedById: self.orientedById
//         )
//     }
// }