import Vapor

struct InstructorsByStationResponseDTO: Content, Codable {
    var stationId: UUID
    var stationName: String
    var instructors: [InstructorDTO]
}
