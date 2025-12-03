import Vapor

extension Request {
    var userService: UserService {
        return UserService(database: self.db, logger: self.logger)
    }

    var badgeService: BadgeService {
        return BadgeService(database: self.db, logger: self.logger)
    }
}
