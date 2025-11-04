import Vapor

struct CardsResponseDTO: Content, Codable {
    var cards: [CardDTO]
}
