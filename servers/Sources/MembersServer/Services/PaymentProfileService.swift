import Fluent

struct PaymentProfileService {
    private let database: any Database
    private let adminLogger: AdminLogService

    init(database: any Database, adminLogger: AdminLogService) {
        self.database = database
        self.adminLogger = adminLogger
    }

    func getPaymentProfile(for id: UUID) async throws -> PaymentProfileResponseDTO? {
        let profile = try await PaymentProfile.query(on: database)
            .filter(\.$id == id)
            .with(\.$user)
            .first()

        return try profile?.toResponseDTO()
    }

    func getPaymentProfiles(for userId: UUID) async throws -> [PaymentProfileResponseDTO] {
        let profiles = try await PaymentProfile.query(on: database)
            .filter(\.$user.$id == userId)
            .sort(\.$createdAt, .descending)
            .all()

        return try profiles.map { try $0.toResponseDTO() }
    }

    func addPaymentProfile(
        asUser: UUID,
        from dto: PaymentProfileRequestDTO,
        to userId: UUID
    ) async throws -> PaymentProfileResponseDTO {
        let userExists = try await User.query(on: database).filter(\.$id == userId).first()
        guard userExists != nil else {
            throw PaymentProfileError.userNotFound
        }

        let profile = dto.toModel(userId: userId)

        return try await database.transaction { tDb in
            do {
                try await profile.save(on: tDb)
            } catch {
                guard let dbError = error as? any DatabaseError,
                      dbError.isConstraintFailure else {
                    throw error
                }
                throw PaymentProfileError.uniqueViolation
            }

            guard let profileId = profile.id else {
                throw ServerError.unexpectedError(reason: "PaymentProfile ID is nil after save")
            }

            try await adminLogger.addLog(
                for: asUser,
                on: tDb,
                "Added payment profile \(profileId) with source \(profile.source.rawValue) for user \(userId)"
            )

            let createdProfile = try await PaymentProfile.query(on: tDb)
                .filter(\.$id == profileId)
                .with(\.$user)
                .first()

            guard let createdProfile else {
                throw ServerError.unexpectedError(
                    reason: "Created payment profile returned nil"
                )
            }

            return try createdProfile.toResponseDTO()
        }
    }

    func deletePaymentProfile(asUser: UUID, id: UUID) async throws {
        try await database.transaction { tDb in
            let profile = try await PaymentProfile.query(on: tDb)
                .filter(\.$id == id)
                .first()

            guard let profile else {
                throw PaymentProfileError.paymentProfileNotFound
            }

            try await profile.delete(on: tDb)

            try await adminLogger.addLog(for: asUser, on: tDb, "Deleted payment profile \(id)")
        }
    }
}
