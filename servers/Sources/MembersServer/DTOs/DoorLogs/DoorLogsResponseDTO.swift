import Vapor

struct DoorLogsResponseDTO: Content, Codable {
    var logs: [DoorLogDTO]
    var total: Int
    var limit: Int
    var offset: Int
}
