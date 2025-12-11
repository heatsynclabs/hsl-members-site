import Vapor

struct StationResponseDTO: Content, Codable {
    var stationId: UUID
    var stationName: String
    var instructors: [InstructorDTO]
}

extension Station {
    func toResponseDTO() throws -> StationResponseDTO {
        guard let id else {
            throw ServerError.unexpectedError(reason: "Station id is missing")
        }

        return StationResponseDTO(
            stationId: id,
            stationName: name,
            instructors: try instructors.map { try $0.toInstructorDTO() }
        )
    }
}
