import Vapor

struct StationBasicDTO: Content, Codable {
    var id: UUID
    var name: String
}

extension Station {
    func toBasicDTO() -> StationBasicDTO {
        return StationBasicDTO(
            id: self.id!,
            name: self.name
        )
    }
}
