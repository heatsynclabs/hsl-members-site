import Fluent
import Foundation

struct StationService {
    private let database: any Database
    private let adminLogger: AdminLogService

    init(database: any Database, adminLogger: AdminLogService) {
        self.database = database
        self.adminLogger = adminLogger
    }

    func getStation(_ id: UUID) async throws -> StationResponseDTO {
        let station = try await getStationWithInstructors(id: id, on: database)
        guard let station else {
            throw StationError.stationNotFound
        }
        return try station.toResponseDTO()
    }

    func getStations() async throws -> [StationListResponseDTO] {
        let stations = try await Station.query(on: database)
            .with(\.$instructors)
            .sort(\.$name, .ascending)
            .all()

        return try stations.map { try $0.toListResponseDTO() }
    }

    func addStation(asUser userId: UUID, from dto: StationRequestDTO) async throws -> StationResponseDTO {
        let model = dto.toModel()

        return try await database.transaction { tDb in
            do {
                try await model.save(on: tDb)
            } catch {
                try stationUniqueChecks(error)
            }

            guard let id = model.id else {
                throw ServerError.unexpectedError(reason: "Station id is missing after creation")
            }

            let station = try await getStationWithInstructors(id: id, on: tDb)
            guard let station else {
                throw ServerError.unexpectedError(reason: "Station not found after creation")
            }

            try await adminLogger.addLog(
                for: userId, on: tDb, "Added station '\(station.name)' with id (\(station.id?.uuidString ?? "unknown"))")

            return try station.toResponseDTO()
        }
    }

    func updateStation(asUser userId: UUID, from dto: StationRequestDTO, for id: UUID) async throws -> StationResponseDTO {
        let station = try await Station.query(on: database)
            .with(\.$instructors) { $0.with(\.$user) }
            .filter(\.$id == id)
            .first()
        guard let station else {
            throw StationError.stationNotFound
        }

        dto.updateModel(station)

        try await database.transaction { tDb in
            do {
                try await station.save(on: tDb)
            } catch {
                try stationUniqueChecks(error)
            }

            try await adminLogger.addLog(for: userId, on: tDb, "Updated station with id \(id.uuidString) to new name \(dto.name)")
        }

        return try station.toResponseDTO()
    }

    func deleteStation(asUser userId: UUID, id: UUID) async throws {
        try await database.transaction { tDb in
            try await Station.query(on: tDb)
                .filter(\.$id == id)
                .delete()

            try await adminLogger.addLog(for: userId, on: tDb, "Deleted station with id \(id.uuidString)")
        }
    }

    private func stationUniqueChecks(_ error: any Error) throws {
        guard let dbError = error as? any DatabaseError else {
            throw error
        }
        let field = dbError.constraintName
        guard let field else {
            throw error
        }

        if field.contains(Station.fieldName.description) {
            throw BadgeError.uniqueViolation(field: .name)
        } else {
            throw error
        }
    }

    private func getStationWithInstructors(id: UUID, on db: any Database) async throws -> Station? {
        return try await Station.query(on: db)
            .with(\.$instructors) { $0.with(\.$user) }
            .filter(\.$id == id)
            .first()
    }
}
