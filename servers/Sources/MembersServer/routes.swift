import Fluent
import Vapor
import VaporToOpenAPI

func routes(_ app: Application) throws {
    app.middleware.use(cors, at: .beginning)

    let v1Router = app.grouped("v1")

    // Open API documentation route
    v1Router.get("swagger", "swagger.json") { req in
        req.application.routes.openAPI(
            info: InfoObject(
                title: "Example API",
                description: "Example API description",
                version: "0.1.0",
            )
        )
    }
    .excludeFromOpenAPI()

    // Health check route
    v1Router.get("health") { _ in
        return ["status": "ok"]
    }

    // Ensures the JWT was validated successfully, and the user was added to the request context
    let jwtProtected = v1Router.grouped(UserAuthenticator(), User.guardMiddleware())
    let openApiProtected = jwtProtected.groupedOpenAPI(auth: .bearer())

    try openApiProtected.register(collection: UserController())
}
