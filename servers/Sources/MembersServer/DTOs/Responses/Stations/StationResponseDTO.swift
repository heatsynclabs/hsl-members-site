import Vapor

struct StationResponseDTO: Content, Codable {
    var stations: [StationDTO]
}
