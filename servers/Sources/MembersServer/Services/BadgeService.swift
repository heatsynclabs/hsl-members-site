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
        try await badgeUniqueChecks(name: dto.name, stationId: dto.stationId)
        let badge = dto.toModel()

        return try await database.transaction { tDb in
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

        if badge.name != dto.name || badge.station.id != dto.stationId {
            try await badgeUniqueChecks(name: dto.name, stationId: dto.stationId)
        }

        dto.updateBadge(badge)

        return try await database.transaction { tDb in
            try await badge.save(on: tDb)

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

    private func badgeUniqueChecks(name: String, stationId: UUID) async throws {
        let nameCount = try await Badge.query(on: database)
            .filter(\.$name == name)
            .count()
        if nameCount > 0 {
            throw BadgeError.uniqueViolation(field: .name)
        }
        let stationCount = try await Badge.query(on: database)
            .filter(\.$station.$id == stationId)
            .count()
        if stationCount > 0 {
            throw BadgeError.uniqueViolation(field: .station)
        }
    }

    private func getBadgeWithStation(id: UUID, on database: any Database) async throws -> Badge? {
        return try await Badge.query(on: database)
            .filter(\.$id == id)
            .with(\.$station)
            .first()
    }
}
