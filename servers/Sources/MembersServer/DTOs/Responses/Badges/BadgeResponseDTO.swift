import struct Foundation.Date
import struct Foundation.UUID
import protocol Vapor.Content

struct BadgeResponseDTO: Content {
    let id: UUID
    let name: String
    let description: String
    let imageURL: String?
    let createdAt: Date
    let updatedAt: Date
    let station: StationBasicDTO
}

extension Badge {
    func toResponseDTO() throws -> BadgeResponseDTO {
        guard let id = self.id else {
            throw ServerError.unexpectedError(reason: "Badge id is missing")
        }
        return BadgeResponseDTO(
            id: id,
            name: name,
            description: description,
            imageURL: imageURL?.absoluteString,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date(),
            station: try station.toBasicDTO()
        )
    }
}
