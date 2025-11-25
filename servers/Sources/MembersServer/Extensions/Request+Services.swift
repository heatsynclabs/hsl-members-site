import Vapor

extension Request {
    var userService: UserService {
        return UserService(database: self.db, logger: self.logger)
    }
}
