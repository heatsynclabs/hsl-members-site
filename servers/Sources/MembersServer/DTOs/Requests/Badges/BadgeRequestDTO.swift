import Vapor

struct BadgeRequestDTO: Content {
    let name: String
    let description: String
    let imageURL: String?
    let stationId: UUID
}

extension BadgeRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: .count(1...100))
        validations.add("description", as: String.self, is: .count(1...500))
        validations.add("imageURL", as: String.self, is: .count(1...1000) && .url, required: false)
        validations.add("stationId", as: UUID.self)
    }
}

extension BadgeRequestDTO {
    func toModel() -> Badge {
        return Badge(
            name: name,
            description: description,
            imageUrlString: imageURL,
            stationId: stationId
        )
    }

    func updateBadge(_ badge: Badge) {
        badge.name = name
        badge.description = description
        badge.imageUrlString = imageURL
        badge.$station.id = stationId
    }
}
