import JWT
import Vapor

struct UserAuthenticator: JWTAuthenticator {
    typealias Payload = JwtUser

    func authenticate(jwt: Payload, for request: Vapor.Request) async throws {
        guard let userId = jwt.id else {
            throw Abort(.unauthorized, reason: "JWT is missing ID or it is not a valid UUID")
        }

        let service = request.userService
        var user = try await service.getUser(for: userId)
        if user == nil {
            user = User(
                id: userId, firstName: jwt.firstName, lastName: jwt.lastName, email: jwt.email)
            user = try await service.createUser(from: user!)
        }

        guard let user else {
            throw Abort(.internalServerError)
        }

        request.auth.login(user)
    }
}
