import Vapor

struct StationBasicDTO: Content, Codable {
    var id: UUID
    var name: String
}

extension Station {
    func toBasicDTO() throws -> StationBasicDTO {
        guard let id else {
            throw ServerError.unexpectedError(reason: "Station id is missing")
        }
        return StationBasicDTO(
            id: id,
            name: self.name
        )
    }
}
