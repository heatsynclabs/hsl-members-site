import Crypto
import Fluent

import struct Foundation.Data
import struct Foundation.Date

struct ApiKeyService {
    private let database: any Database
    private let adminLogger: AdminLogService

    init(database: any Database, adminLogger: AdminLogService) {
        self.database = database
        self.adminLogger = adminLogger
    }

    func getApiKey(for id: UUID) async throws -> ApiKeyResponseDTO? {
        let apiKey = try await ApiKey.query(on: database)
            .filter(\.$id == id)
            .with(\.$user)
            .first()

        guard let apiKey else {
            return nil
        }

        return apiKey.toResponseDTO(withKey: "")
    }

    func getApiKeys(for userId: UUID) async throws -> [ApiKeyResponseDTO] {
        let apiKeys = try await ApiKey.query(on: database)
            .filter(\.$user.$id == userId)
            .sort(\.$createdAt, .descending)
            .all()

        return apiKeys.map { $0.toResponseDTO(withKey: "") }
    }

    func createApiKey(
        asUser: UUID,
        for userId: UUID,
        from dto: ApiKeyRequestDTO
    ) async throws -> ApiKeyResponseDTO {
        let userExists = try await User.query(on: database).filter(\.$id == userId).first()
        guard userExists != nil else {
            throw ApiKeyError.userNotFound
        }

        let key = generateApiKey()
        let hashedKey = hashKey(key)

        let apiKey = ApiKey(
            userId: userId,
            name: dto.name,
            keyHash: hashedKey,
            isActive: true,
            expiresAt: dto.expiresAt,
            createdBy: asUser
        )

        return try await database.transaction { tDb in
            try await apiKey.save(on: tDb)

            guard let apiKeyId = apiKey.id else {
                throw ServerError.unexpectedError(reason: "ApiKey ID is nil after save")
            }

            try await adminLogger.addLog(
                for: asUser,
                on: tDb,
                "Created API key \(apiKeyId) named \(dto.name) for user \(userId)"
            )

            let createdApiKey = try await ApiKey.query(on: tDb)
                .filter(\.$id == apiKeyId)
                .with(\.$user)
                .first()

            guard let createdApiKey else {
                throw ServerError.unexpectedError(
                    reason: "Created API key returned nil"
                )
            }

            return createdApiKey.toResponseDTO(withKey: key)
        }
    }

    func deleteApiKey(asUser: UUID, id: UUID) async throws {
        try await database.transaction { tDb in
            let apiKey = try await ApiKey.query(on: tDb)
                .filter(\.$id == id)
                .first()

            guard let apiKey else {
                throw ApiKeyError.apiKeyNotFound
            }

            try await apiKey.delete(on: tDb)

            try await adminLogger.addLog(for: asUser, on: tDb, "Deleted API key \(id)")
        }
    }

    func verifyApiKey(_ key: String) async throws -> ApiKey {
        let hashedKey = hashKey(key)

        guard let apiKey = try await ApiKey.query(on: database)
            .filter(\.$keyHash == hashedKey)
            .filter(\.$isActive == true)
            .first() else {
            throw ApiKeyError.invalidApiKey
        }

        if !apiKey.isActive {
            throw ApiKeyError.apiKeyInactive
        }

        if let expiresAt = apiKey.expiresAt, expiresAt < Date() {
            throw ApiKeyError.apiKeyExpired
        }

        return apiKey
    }

    private func generateApiKey() -> String {
        return "hsl_" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }

    private func hashKey(_ key: String) -> String {
        let data = Data(key.utf8)
        let hashedData = SHA256.hash(data: data)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}
