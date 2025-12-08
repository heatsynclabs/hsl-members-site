import Fluent

struct BadgeService {
    private let database: any Database
    private let logger: Logger

    init(database: any Database, logger: Logger) {
        self.database = database
        self.logger = logger
    }

    func getBadge(for id: UUID) async throws -> BadgeResponseDTO? {
        let badge = try await getBadgeWithStation(id: id, on: database)
        return try badge?.toResponseDTO()
    }

    func getAllBadges() async throws -> [BadgeResponseDTO] {
        let badges = try await Badge.query(on: database)
            .with(\.$station)
            .all()

        return try badges.map { try $0.toResponseDTO() }
    }

    func addBadge(from dto: BadgeRequestDTO) async throws -> BadgeResponseDTO {
        let badge = dto.toModel()

        return try await database.transaction { tDb in
            do {
                try await badge.save(on: tDb)
            } catch {
                try badgeUniqueChecks(error)
            }
            try await badge.save(on: tDb)
            guard let badgeId = badge.id else {
                throw ServerError.unexpectedError(reason: "Badge ID is nil after save")
            }

            let createdBadge = try await getBadgeWithStation(id: badgeId, on: tDb)
            guard let createdBadge else {
                throw ServerError.unexpectedError(reason: "Created badge returned nil")
            }

            return try createdBadge.toResponseDTO()
        }
    }

    func updateBadge(from dto: BadgeRequestDTO, for id: UUID) async throws -> BadgeResponseDTO {
        let badge = try await getBadgeWithStation(id: id, on: database)
        guard let badge else {
            throw BadgeError.badgeNotFound
        }

        dto.updateBadge(badge)

        return try await database.transaction { tDb in
            do {
                try await badge.save(on: tDb)
            } catch {
                try badgeUniqueChecks(error)
            }

            let updatedBadge = try await getBadgeWithStation(id: id, on: tDb)
            guard let updatedBadge else {
                throw ServerError.unexpectedError(reason: "Updated badge returned nil")
            }

            return try updatedBadge.toResponseDTO()
        }
    }

    func deleteBadge(id: UUID) async throws {
        try await Badge.query(on: database)
            .filter(\.$id == id)
            .delete()
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
