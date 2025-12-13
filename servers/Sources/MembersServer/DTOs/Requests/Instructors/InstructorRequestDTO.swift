import Foundation
import Vapor

struct InstructorRequestDTO: Content, Codable {
    let userId: UUID
}

extension InstructorRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("userId", as: UUID.self, is: .valid)
    }
}
