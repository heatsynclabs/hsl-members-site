import Vapor

struct StationRequestDTO: Content, Codable {
    let name: String
}

extension StationRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: .count(1...100) && !.empty)
    }
}

extension StationRequestDTO {
    func toModel() -> Station {
        return Station(name: name)
    }

    func updateModel(_ station: Station) {
        station.name = name
    }
}
