import Vapor

extension Request {
    var userService: UserService {
        return UserService(database: self.db)
    }

    var badgeService: BadgeService {
        return BadgeService(database: self.db)
    }

    var stationService: StationService {
        return StationService(database: self.db, adminLogger: self.adminLogService)
    }

    var instructorService: InstructorService {
        return InstructorService(database: self.db, adminLogger: self.adminLogService)
    }

    var adminLogService: AdminLogService {
        return AdminLogService(database: self.db)
    }
}
