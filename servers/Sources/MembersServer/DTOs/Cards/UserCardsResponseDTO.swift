import Vapor

struct UserCardsResponseDTO: Content, Codable {
    var userCards: [UserCardDTO]
}
