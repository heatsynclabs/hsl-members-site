import Vapor

struct InstructorDTO: Content, Codable {
    var userId: UUID
    var firstName: String
    var lastName: String
    var email: String
    var certifiedAt: Date
}

extension Instructor {
    func toInstructorDTO() throws -> InstructorDTO {
        guard let id else {
            throw ServerError.unexpectedError(reason: "Instructor id is missing")
        }

        return InstructorDTO(
            userId: id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            certifiedAt: createdAt ?? Date()
        )
    }
}
