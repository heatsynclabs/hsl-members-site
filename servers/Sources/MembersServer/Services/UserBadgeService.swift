import Fluent

struct UserBadgeService {
    private let database: any Database
    private let adminLogger: AdminLogService

    init(database: any Database, adminLogger: AdminLogService) {
        self.database = database
        self.adminLogger = adminLogger
    }

    func addBadge(_ badgeId: UUID, asUser: User, for userId: UUID) async throws -> UserBadgeDTO {
        if !asUser.instructorForStations.contains(where: { $0.id == badgeId }) {
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

            let asUserId = try asUser.requireID()
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

    func deleteBadge(_ badgeId: UUID, asUser: User, for userID: UUID) async throws {
        if !asUser.instructorForStations.contains(where: { $0.id == badgeId }) {
            throw UserBadgeError.notInstructorForStation
        }

        try await database.transaction { tDb in
            try await UserBadge.query(on: tDb)
                .filter(\.$badge.$id == badgeId)
                .filter(\.$user.$id == userID)
                .delete()

            let asUserID = try asUser.requireID()

            try await adminLogger.addLog(for: asUserID, on: tDb, "Deleted badge \(badgeId) from user \(userID)")
        }
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
