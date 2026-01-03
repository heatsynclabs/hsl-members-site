import Foundation
import Vapor

struct UserBadgeRequestDTO: Content {
    let badgeId: UUID
}

extension UserBadgeRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("badgeId", as: UUID.self, is: .valid)
    }
}
