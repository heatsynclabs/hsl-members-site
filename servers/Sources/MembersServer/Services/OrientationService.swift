import Fluent
import Vapor

struct OrientationService {
    private let db: any Database
    private let logger: Logger

    init(db: any Database, logger: Logger) {
        self.db = db
        self.logger = logger
    }

    // func getOrientations() async throws -> [Orie] {
    //     let orientations = try await Orientation.query(on: db).all()
    //     return orientations.map { $0.toDTO() }
    // }
}
