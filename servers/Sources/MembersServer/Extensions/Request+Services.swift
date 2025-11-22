import Vapor

extension Request {
    var userService: UserService {
        return UserService(db: self.db, logger: self.logger)
    }
}
