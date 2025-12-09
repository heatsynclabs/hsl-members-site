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
    }

    func getStation(req: Request) async throws -> StationResponseDTO {
        let stationId = req.parameters.get(Self.stationIdParam, as: UUID.self)
        guard let stationId else {
            throw Self.missingIdError
        }

        let station = try await req.stationService.getStation(stationId)
        return station
    }
}
