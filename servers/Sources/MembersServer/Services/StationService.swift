import Fluent
import Foundation

struct StationService {
    private let database: any Database

    init(database: any Database) {
        self.database = database
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

    func addStation(from dto: StationRequestDTO) async throws -> StationResponseDTO {
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
            return try station.toResponseDTO()
        }
    }

    func updateStation(from dto: StationRequestDTO, for id: UUID) async throws -> StationResponseDTO {
        let station = try await Station.query(on: database)
            .with(\.$instructors) { $0.with(\.$user) }
            .filter(\.$id == id)
            .first()
        guard let station else {
            throw StationError.stationNotFound
        }

        dto.updateModel(station)

        do {
            try await station.save(on: database)
        } catch {
            try stationUniqueChecks(error)
        }

        return try station.toResponseDTO()
    }

    func deleteStation(id: UUID) async throws {
        try await Station.query(on: database)
            .filter(\.$id == id)
            .delete()
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
