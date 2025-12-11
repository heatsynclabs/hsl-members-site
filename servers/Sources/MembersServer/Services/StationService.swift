import Fluent
import Foundation

struct StationService {
    private let database: any Database

    init(database: any Database) {
        self.database = database
    }

    func getStation(_ id: UUID) async throws -> StationResponseDTO {
        let station = try await Station.query(on: database)
            .with(\.$instructors) { $0.with(\.$user) }
            .filter(\.$id == id)
            .first()
        guard let station else {
            throw StationError.stationNotFound
        }
        return try station.toResponseDTO()
    }

    func getStations() async throws -> [StationListResponseDTO] {
        let stations = try await Station.query(on: database)
            .with(\.$instructors)
            .sort(\.$createdAt, .descending)
            .all()

        return try stations.map { try $0.toListResponseDTO() }
    }

    func addBadge(from dto: StationRequestDTO) async throws -> StationResponseDTO {
        let model = dto.toModel()

        return try await database.transaction { tDb in
            do {
                try await model.save(on: tDb)
            } catch {
                try stationUniqueChecks(error)
            }
            _ = try await model.$instructors.query(on: tDb).with(\.$user).all()
            return try model.toResponseDTO()
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
}
