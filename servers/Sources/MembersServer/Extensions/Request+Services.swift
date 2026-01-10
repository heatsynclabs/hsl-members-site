import Vapor

extension Request {
    var userService: UserService {
        return UserService(database: self.db, webhookService: self.webhookService)
    }

    var badgeService: BadgeService {
        return BadgeService(database: self.db, adminLogger: self.adminLogService)
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

    var userBadgeService: UserBadgeService {
        return UserBadgeService(database: self.db, adminLogger: self.adminLogService)
    }

    var webhookService: WebhookService {
        return WebhookService(
            client: self.client,
            logger: self.logger,
            webhookURL: Environment.get("MEMBER_WEBHOOK_URL"),
            webhookSecret: Environment.get("MEMBER_WEBHOOK_SECRET")
        )
    }
}
