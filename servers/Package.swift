// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "servers",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // 🐘 Fluent driver for Postgres.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.8.0"),
        // Fluent driver for SQLite (for testing)
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.8.1"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        // Vapor JWT
        .package(url: "https://github.com/vapor/jwt.git", from: "5.0.0"),

        // Supabase for generating tokens for testing
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.37.0"),

        // Swift Arugment Parser for CLI commands
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.2"),

        // OpenAPI/Swagger generation
        .package(url: "https://github.com/dankinsoid/VaporToOpenAPI.git", from: "4.9.1")
    ],
    targets: [
        .executableTarget(
            name: "MembersServer",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "VaporToOpenAPI", package: "VaporToOpenAPI")
            ],
            swiftSettings: swiftSettings
        ),
        .executableTarget(
            name: "JwtGenerator",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/Tools/JwtGenerator",
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "MembersServerTest",
            dependencies: [
                .target(name: "MembersServer"),
                .product(name: "VaporTesting", package: "vapor")
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] {
    [
        .enableUpcomingFeature("ExistentialAny")
    ]
}
