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
}
