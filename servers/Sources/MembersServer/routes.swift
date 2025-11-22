import Fluent
import Vapor
import VaporToOpenAPI

func routes(_ app: Application) throws {
    // Open API documentation route
    app.get("swagger", "swagger.json") { req in
        req.application.routes.openAPI(
            info: InfoObject(
                title: "Example API",
                description: "Example API description",
                version: "0.1.0",
            )
        )
    }
    .excludeFromOpenAPI()

    // Ensures the JWT was validated successfully, and the user was added to the request context
    let jwtProtected = app.grouped(UserAuthenticator(), User.guardMiddleware())
    let openApiProtected = jwtProtected.groupedOpenAPI(auth: .bearer())

    try openApiProtected.register(collection: UserController())
}
