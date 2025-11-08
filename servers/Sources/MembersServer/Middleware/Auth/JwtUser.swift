import JWT
import Vapor

struct JwtUser: Authenticatable, Content, JWTPayload {
    let expiration: ExpirationClaim
    let sub: SubjectClaim
    let email: String

    var id: UUID? {
        UUID(uuidString: sub.value)
    }

    func verify(using algorithm: some JWTKit.JWTAlgorithm) async throws {
        try expiration.verifyNotExpired()
    }
}
