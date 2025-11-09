import JWT
import Vapor

struct UserAuthenticator: JWTAuthenticator {
    typealias Payload = JwtUser

    func authenticate(jwt: Payload, for request: Vapor.Request) async throws {
        guard let userId = jwt.id else {
            throw Abort(.unauthorized, reason: "JWT is missing ID or it is not a valid UUID")
        }

        var user = try await User.find(userId, on: request.db)
        if user == nil {
            user = User(
                id: userId, firstName: jwt.firstName, lastName: jwt.lastName, email: jwt.email)
            try await user!.save(on: request.db)
        }

        guard let user else {
            throw Abort(.internalServerError)
        }

        request.auth.login(user)
    }
}
