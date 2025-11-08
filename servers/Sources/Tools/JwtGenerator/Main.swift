import ArgumentParser

import struct Foundation.URL

@main
struct Entrypoint: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "jwt-generator",
        abstract: "A tool to generate JWTs for testing the Members Server.",
        subcommands: [Login.self, CreateUser.self],
    )
}
