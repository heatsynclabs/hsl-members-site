import Vapor

struct StationsResponseDTO: Content, Codable {
    var stations: [StationWithCountDTO]
}
