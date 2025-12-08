import Fluent
import PostgresNIO
import SQLiteNIO

extension DatabaseError {
    var constraintName: String? {
        guard self.isConstraintFailure else { return nil }

        if let psqlError = self as? PSQLError,
            let serverInfo = psqlError.serverInfo,
            let constraint = serverInfo[.constraintName] {
            return constraint
        }

        if let sqliteError = self as? SQLiteError {
            let message = sqliteError.message
            let prefix = "UNIQUE constraint failed: "

            if message.hasPrefix(prefix) {
                return String(message.dropFirst(prefix.count))
            }
        }

        return nil
    }
}
