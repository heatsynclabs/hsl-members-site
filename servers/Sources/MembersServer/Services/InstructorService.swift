import Fluent
import Foundation

struct InstructorService {
    private let database: any Database
    private let adminLogger: AdminLogService

    init(database: any Database, adminLogger: AdminLogService) {
        self.database = database
        self.adminLogger = adminLogger
    }

    func addInstructor(asUser: UUID, to stationId: UUID, userId: UUID) async throws -> InstructorDTO {
        let user = try await User.find(userId, on: database)
        guard user != nil else {
            throw UserError.userNotFound
        }
        let station = try await Station.find(stationId, on: database)
        guard station != nil else {
            throw StationError.stationNotFound
        }

        do {
            return try await database.transaction { tDb in
                let instructor = Instructor(userID: userId, stationID: stationId)
                try await instructor.save(on: tDb)
                try await instructor.$user.load(on: tDb)

                try await adminLogger.addLog(for: asUser, on: tDb, "Added user \(userId) as an instructor to station \(stationId)")

                return try instructor.toInstructorDTO()
            }
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

    func deleteInstructor(asUser: UUID, userId: UUID, stationId: UUID) async throws {
        try await database.transaction { tDb in
            try await Instructor.query(on: tDb)
                .filter(\.$user.$id == userId)
                .filter(\.$station.$id == stationId)
                .delete()

            try await adminLogger.addLog(for: asUser, on: tDb, "Delete user \(userId) as an instructor for station \(stationId)")
        }
    }
}
