import Fluent

struct UserBadgeService {
    private let database: any Database
    private let adminLogger: AdminLogService

    init(database: any Database, adminLogger: AdminLogService) {
        self.database = database
        self.adminLogger = adminLogger
    }

    func addBadge(_ badgeId: UUID, asUser: User, for userId: UUID) async throws -> UserBadgeDTO {
        if !asUser.instructorForStations.contains { $0.id == badgeId } {
            throw UserBadgeError.notInstructorForStation
        }

        let userBadge = UserBadge(badgeId: badgeId, userId: userId)

        let badge = try await database.transaction { tDb in
            do {
                try await userBadge.save(on: tDb)
            } catch {
                try userBadgeUniqueChecks(error)
            }
            guard let userBadgeId = userBadge.id else {
                throw ServerError.unexpectedError(reason: "User Badge ID is nil after save")
            }

            guard let asUserId = asUser.id else {
                throw ServerError.unexpectedError(reason: "As User Id is nil")
            }
            try await adminLogger.addLog(for: asUserId, on: tDb, "Added badge \(badgeId) to user \(userId)")

            let createdBadge = try await UserBadge.query(on: tDb)
                .with(\.$user)
                .with(\.$badge)
                .filter(\.$id == userBadgeId)
                .first()
            guard let createdBadge else {
                throw ServerError.unexpectedError(reason: "Created badge returned nil on lookup")
            }

            return createdBadge
        }

        return try badge.toDTO()
    }

    func deleteBadge(_ badgeId: UUID, asUser: User, for: User) async throws {

    }

    private func userBadgeUniqueChecks(_ error: any Error) throws {
        guard let dbError = error as? any DatabaseError else {
            throw error
        }
        let field = dbError.constraintName
        guard let field else {
            throw error
        }

        if field.contains("badge") {
            throw UserBadgeError.uniqueViolation(field: .badge)
        }

        throw error
    }
}
