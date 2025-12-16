import Fluent

struct AdminLogService {
    private let database: any Database

    init(database: any Database) {
        self.database = database
    }

    func getLogs(page: PageRequest) async throws -> Page<AdminLogDTO> {
        let logs = try await AdminLog.query(on: database)
            .with(\.$user) { $0.with(\.$membershipLevel) }
            .paginate(page)

        return try logs.map { try $0.toDTO() }
    }

    func addLog(for userId: UUID, on db: (any Database)? = nil, _ log: String) async throws {
        let targetDB = db ?? database

        let log = AdminLog(userId: userId, log: log)
        try await log.save(on: targetDB)
    }
}
