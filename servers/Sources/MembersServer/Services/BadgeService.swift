import Fluent

struct BadgeService {
    private let database: any Database
    private let adminLogger: AdminLogService

    init(database: any Database, adminLogger: AdminLogService) {
        self.database = database
        self.adminLogger = adminLogger
    }

    func getBadge(for id: UUID) async throws -> BadgeResponseDTO? {
        let badge = try await getBadgeWithStation(id: id, on: database)
        return try badge?.toResponseDTO()
    }

    func getAllBadges() async throws -> [BadgeResponseDTO] {
        let badges = try await Badge.query(on: database)
            .with(\.$station)
            .sort(\.$name, .ascending)
            .all()

        return try badges.map { try $0.toResponseDTO() }
    }

    func addBadge(asUser: UUID, from dto: BadgeRequestDTO) async throws -> BadgeResponseDTO {
        let badge = dto.toModel()

        return try await database.transaction { tDb in
            do {
                try await badge.save(on: tDb)
            } catch {
                try badgeUniqueChecks(error)
            }
            guard let badgeId = badge.id else {
                throw ServerError.unexpectedError(reason: "Badge ID is nil after save")
            }

            try await adminLogger.addLog(for: asUser, on: tDb, "Added badge \(badgeId) with name \(badge.name)")

            let createdBadge = try await getBadgeWithStation(id: badgeId, on: tDb)
            guard let createdBadge else {
                throw ServerError.unexpectedError(reason: "Created badge returned nil")
            }

            return try createdBadge.toResponseDTO()
        }
    }

    func updateBadge(asUser: UUID, from dto: BadgeRequestDTO, for id: UUID) async throws -> BadgeResponseDTO {
        let badge = try await getBadgeWithStation(id: id, on: database)
        guard let badge else {
            throw BadgeError.badgeNotFound
        }

        dto.updateBadge(badge)

        do {
            try await database.transaction { tDb in
                try await badge.save(on: tDb)
                try await adminLogger.addLog(for: asUser, on: tDb, "Updated badge \(id) to name \(badge.name)")
            }
        } catch {
            try badgeUniqueChecks(error)
        }

        return try badge.toResponseDTO()
    }

    func deleteBadge(asUser: UUID, id: UUID) async throws {
        try await database.transaction { tDb in
            try await Badge.query(on: tDb)
                .filter(\.$id == id)
                .delete()

            try await adminLogger.addLog(for: asUser, on: tDb, "Deleted badge \(id)")
        }
    }

    private func badgeUniqueChecks(_ error: any Error) throws {
        guard let dbError = error as? any DatabaseError else {
            throw error
        }
        let field = dbError.constraintName
        guard let field else {
            throw error
        }

        if field.contains(Badge.fieldName.description) {
            throw BadgeError.uniqueViolation(field: .name)
        } else if field.contains(Badge.fieldStationdId.description) {
            throw BadgeError.uniqueViolation(field: .station)
        } else {
            throw error
        }
    }

    private func getBadgeWithStation(id: UUID, on database: any Database) async throws -> Badge? {
        return try await Badge.query(on: database)
            .filter(\.$id == id)
            .with(\.$station)
            .first()
    }
}
