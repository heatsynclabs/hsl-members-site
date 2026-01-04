import Fluent

struct DonationService {
    private let database: any Database
    private let adminLogger: AdminLogService

    init(database: any Database, adminLogger: AdminLogService) {
        self.database = database
        self.adminLogger = adminLogger
    }

    func getDonation(for id: UUID) async throws -> DonationResponseDTO? {
        let donation = try await Donation.query(on: database)
            .filter(\.$id == id)
            .with(\.$user)
            .first()

        return try donation?.toResponseDTO()
    }

    func getAllDonations() async throws -> [DonationResponseDTO] {
        let donations = try await Donation.query(on: database)
            .sort(\.$createdAt, .descending)
            .with(\.$user)
            .all()

        return try donations.map { try $0.toResponseDTO() }
    }

    func getDonations(for userId: UUID) async throws -> [DonationResponseDTO] {
        let donations = try await Donation.query(on: database)
            .filter(\.$user.$id == userId)
            .sort(\.$createdAt, .descending)
            .all()

        return try donations.map { try $0.toResponseDTO() }
    }

    func addDonation(asUser: UUID, from dto: DonationRequestDTO) async throws -> DonationResponseDTO {
        if let userId = dto.userId {
            let userExists = try await User.query(on: database).filter(\.$id == userId).first()
            guard userExists != nil else {
                throw DonationError.userNotFound
            }
        }

        let donation = dto.toModel()

        return try await database.transaction { tDb in
            try await donation.save(on: tDb)

            guard let donationId = donation.id else {
                throw ServerError.unexpectedError(reason: "Donation ID is nil after save")
            }

            try await adminLogger.addLog(
                for: asUser,
                on: tDb,
                "Added donation \(donationId) for \(donation.amountInCents) cents"
            )

            let createdDonation = try await Donation.query(on: tDb)
                .filter(\.$id == donationId)
                .with(\.$user)
                .first()

            guard let createdDonation else {
                throw ServerError.unexpectedError(
                    reason: "Created donation returned nil"
                )
            }

            return try createdDonation.toResponseDTO()
        }
    }

    func updateDonation(asUser: UUID, from dto: DonationRequestDTO, for id: UUID) async throws -> DonationResponseDTO {
        let donation = try await Donation.query(on: database)
            .filter(\.$id == id)
            .with(\.$user)
            .first()

        guard let donation else {
            throw DonationError.donationNotFound
        }

        dto.updateDonation(donation)

        try await database.transaction { tDb in
            try await donation.save(on: tDb)
            try await adminLogger.addLog(for: asUser, on: tDb, "Updated donation \(id)")
        }

        return try donation.toResponseDTO()
    }

    func deleteDonation(asUser: UUID, id: UUID) async throws {
        try await database.transaction { tDb in
            let donation = try await Donation.query(on: tDb)
                .filter(\.$id == id)
                .first()

            guard let donation else {
                throw DonationError.donationNotFound
            }

            try await donation.delete(on: tDb)

            try await adminLogger.addLog(for: asUser, on: tDb, "Deleted donation \(id)")
        }
    }
}
