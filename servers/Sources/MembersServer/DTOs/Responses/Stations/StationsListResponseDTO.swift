import Vapor

struct StationListResponseDTO: Content, Codable {
    var id: UUID
    var name: String
    var instructorCount: Int
    var createdAt: Date
    var updatedAt: Date
}

extension Station {
    func toListResponseDTO() throws -> StationListResponseDTO {
        guard let id, let createdAt, let updatedAt else {
            throw ServerError.unexpectedError(reason: "Station id or timestamps are missing")
        }
        return StationListResponseDTO(
            id: id,
            name: name,
            instructorCount: instructors.count,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
