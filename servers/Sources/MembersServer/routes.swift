import Fluent
import Vapor

func routes(_ app: Application) throws {
    let jwtProtected = app.grouped(UserAuthenticator())
    jwtProtected.get { req async throws in
        let user = try req.auth.require(User.self)
        return
            "It works! User: \(user.firstName) \(user.lastName), Email: \(user.email), ID: \(user.id!.uuidString)"
    }

    //try app.register(collection: TodoController())
}
