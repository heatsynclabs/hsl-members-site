import Fluent
import Foundation

struct InstructorService {
    private let database: any Database

    init(database: any Database) {
        self.database = database
    }

    func addInstructor(to stationId: UUID, userId: UUID) async throws -> InstructorDTO {
        let user = try await User.find(userId, on: database)
        guard user != nil else {
            throw UserError.userNotFound
        }
        let station = try await Station.find(stationId, on: database)
        guard station != nil else {
            throw StationError.stationNotFound
        }

        do {
            let instructor = Instructor(userID: userId, stationID: stationId)
            try await instructor.save(on: database)
            try await instructor.$user.load(on: database)

            return try instructor.toInstructorDTO()
        } catch {
            if let dbError = error as? any DatabaseError, dbError.isConstraintFailure {
                let constraint = dbError.constraintName?.lowercased()
                switch true {
                case constraint?.contains("instructor"): throw InstructorError.uniqueViolation(field: .instructor)
                default: throw ServerError.unexpectedError(reason: "Unexpected contraint failure: \(dbError)")
                }
            }
            throw error
        }
    }

    func deleteInstructor(userId: UUID, stationId: UUID) async throws {
        try await Instructor.query(on: database)
            .filter(\.$user.$id == userId)
            .filter(\.$station.$id == stationId)
            .delete()
    }
}
