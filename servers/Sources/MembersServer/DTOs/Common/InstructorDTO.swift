import Vapor

struct InstructorDTO: Content, Codable {
    var userId: UUID
    var firstName: String
    var lastName: String
    var email: String
    var certifiedAt: Date
}
