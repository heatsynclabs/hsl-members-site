import Fluent
import FluentPostgresDriver
import JWT
import NIOSSL
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // region Database Configuration and Migrations
    app.databases.use(
        DatabaseConfigurationFactory.postgres(
            configuration: .init(
                hostname: Environment.get("POSTGRES_HOST") ?? "localhost",
                port: Environment.get("POSTGRES_PORT").flatMap(Int.init(_:))
                    ?? SQLPostgresConfiguration.ianaPortNumber,
                username: Environment.get("POSTGRES_USER") ?? "vapor_username",
                password: Environment.get("POSTGRES_PASSWORD") ?? "vapor_password",
                database: Environment.get("POSTGRES_DB") ?? "vapor_database",
                tls: .prefer(try .init(configuration: .clientDefault)))
        ), as: .psql)

    app.migrations.add(CreateInitialSchema())
    try await app.autoMigrate()
    //endregion

    // region JWT Configuration
    let jwkStr = Environment.get("SUPABASE_JWK")
    guard let jwkStr else {
        fatalError("Missing SUPABASE_JWK environment variable")
    }
    let jwk = try JWK(json: jwkStr)
    try await app.jwt.keys.add(jwk: jwk)
    // endregion

    // region Route Registration
    try routes(app)
    // endregion
}
