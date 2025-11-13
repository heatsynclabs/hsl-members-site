import Fluent
import Vapor

func routes(_ app: Application) throws {
    // Ensures the JWT was validated successfully, and the user was added to the request context
    let jwtProtected = app.grouped(UserAuthenticator(), User.guardMiddleware())

    try jwtProtected.register(collection: UserController())
}
