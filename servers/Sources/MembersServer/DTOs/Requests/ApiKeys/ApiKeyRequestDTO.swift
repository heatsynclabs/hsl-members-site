import Vapor
import struct Foundation.Date
import struct Foundation.UUID

struct ApiKeyRequestDTO: Content {
    let name: String
    let expiresAt: Date?
}

extension ApiKeyRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: .count(1...100))
    }
}

struct ApiKeyResponseDTO: Content {
    let id: UUID
    let userId: UUID
    let name: String
    let key: String
    let isActive: Bool
    let expiresAt: Date?
    let createdAt: Date
    let createdBy: UUID
}

extension ApiKey {
    func toResponseDTO(withKey key: String) -> ApiKeyResponseDTO {
        guard let id = self.id else {
            fatalError("ApiKey id is missing")
        }
        return ApiKeyResponseDTO(
            id: id,
            userId: $user.id,
            name: name,
            key: key,
            isActive: isActive,
            expiresAt: expiresAt,
            createdAt: createdAt ?? Date(),
            createdBy: createdBy
        )
    }
}
