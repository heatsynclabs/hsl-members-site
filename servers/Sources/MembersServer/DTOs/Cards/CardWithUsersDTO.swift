import Vapor

struct CardWithUsersDTO: Content, Codable {
    var card: CardDTO
    var userAssignments: [CardUserDTO]
}
