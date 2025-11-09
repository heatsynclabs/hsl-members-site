import JWT
import Vapor

struct JwtUser: Authenticatable, Content, JWTPayload {
    let expiration: ExpirationClaim
    let subject: SubjectClaim
    let email: String
    let metadata: JwtMetadata?

    var firstName: String {
        metadata?.firstName ?? "New"
    }

    var lastName: String {
        metadata?.lastName ?? "User"
    }

    var id: UUID? {
        UUID(uuidString: subject.value)
    }

    struct JwtMetadata: Codable {
        let firstName: String?
        let lastName: String?

        enum CodingKeys: String, CodingKey {
            case firstName = "first_name"
            case lastName = "last_name"
        }
    }

    /// Runs AFTER decoding and signature validation
    /// and can be used to validate claims outside of signature
    func verify(using algorithm: some JWTKit.JWTAlgorithm) async throws {
        try expiration.verifyNotExpired()
    }

    enum CodingKeys: String, CodingKey {
        case expiration = "exp"
        case subject = "sub"
        case email
        case metadata = "user_metadata"
    }
}
