import Fluent
import Vapor
import VaporToOpenAPI

struct StationsController: RouteCollection {
    private static let stationIdParam = "stationId"
    private static let missingIdError = Abort(.badRequest, reason: "Invalid or missing station ID parameter.")

    func boot(routes: any RoutesBuilder) throws {
        let stations = routes.grouped("stations")

        stations.get(":\(Self.stationIdParam)", use: self.getStation)
            .openAPI(
                summary: "Get a station by id",
                description: "Retrieves a station by the provided id",
                response: .type(StationResponseDTO.self)
            )

        stations.get(use: self.getStations)
            .openAPI(
                summary: "Get all stations",
                description: "Get a list of all stations",
                response: .type([StationListResponseDTO].self)
            )

        stations.post(":\(Self.stationIdParam)", use: addStation)
            .openAPI(
                summary: "Add a new station",
                description: "Add a new station to the system (admin only)",
                body: .type(StationRequestDTO.self),
                response: .type(StationResponseDTO.self)
            )
    }

    @Sendable
    func getStation(req: Request) async throws -> StationResponseDTO {
        let stationId = req.parameters.get(Self.stationIdParam, as: UUID.self)
        guard let stationId else {
            throw Self.missingIdError
        }

        let station = try await req.stationService.getStation(stationId)
        return station
    }

    @Sendable
    func getStations(req: Request) async throws -> [StationListResponseDTO] {
        return try await req.stationService.getStations()
    }

    @Sendable
    func addStation(req: Request) async throws -> StationResponseDTO {
        let curUser = try req.auth.require(User.self)
        guard curUser.isAdmin else {
            throw UserError.userNotAdmin
        }

        try StationRequestDTO.validate(content: req)
        let stationDTO = try req.content.decode(StationRequestDTO.self)

        return try await req.stationService.addBadge(from: stationDTO)
    }
}
