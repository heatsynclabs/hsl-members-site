import Vapor

struct CardsResponseDTO: Content, Codable {
    var cards: [CardWithUsersDTO]
}
