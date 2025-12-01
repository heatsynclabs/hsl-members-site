import struct Foundation.Date
import struct Foundation.UUID
import protocol Vapor.Content

struct UserBadgeDTO: Content {
    let badgeId: UUID
    let name: String
    let description: String
    let imageURL: String?
    let earnedAt: Date
    let station: StationBasicDTO
}

extension UserBadge {
    func toDTO() throws -> UserBadgeDTO {
        guard let badgeId = badge.id else {
            throw ServerError.unexpectedError(reason: "Badge id is missing")
        }
        let stationDTO = try badge.station.toBasicDTO()
        return UserBadgeDTO(
            badgeId: badgeId,
            name: badge.name,
            description: badge.description,
            imageURL: badge.imageURL?.absoluteString,
            earnedAt: createdAt ?? Date(),
            station: stationDTO
        )
    }
}
