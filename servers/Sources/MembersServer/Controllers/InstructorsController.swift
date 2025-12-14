import Vapor
import VaporToOpenAPI

struct InstructorsController: RouteCollection {
    private static let stationIdParam = "stationId"
    private static let missingStationIdError = Abort(.badRequest, reason: "Invalid or missing station ID parameter.")

    private static let instructorIdParam = "instructorId"
    private static let missingInstructorIdError = Abort(.badRequest, reason: "Invalid or missing instructor ID parameter.")

    func boot(routes: any RoutesBuilder) throws {
        let router = routes.grouped("stations", ":\(Self.stationIdParam)", "instructors")

        router.post(use: self.addInstructorToStation)
            .openAPI(
                summary: "Add a new instructor",
                description: "A a new instructor for a station (admin only)",
                body: .type(InstructorRequestDTO.self),
                response: .type(InstructorDTO.self)
            )

        router.delete([":\(Self.instructorIdParam)"], use: self.deleteInstructor)
            .openAPI(
                summary: "Delete an instructor",
                description: "Delete an instructor by id (admin only)"
            )
    }

    @Sendable
    func addInstructorToStation(req: Request) async throws -> InstructorDTO {
        let curUser = try req.auth.require(User.self)
        guard curUser.isAdmin else {
            throw UserError.userNotAdmin
        }

        try InstructorRequestDTO.validate(content: req)

        let dto = try req.content.decode(InstructorRequestDTO.self)
        guard let stationId = req.parameters.get(Self.stationIdParam, as: UUID.self) else {
            throw Self.missingStationIdError
        }

        return try await req.instructorService.addInstructor(to: stationId, userId: dto.userId)
    }

    @Sendable
    func deleteInstructor(req: Request) async throws -> HTTPStatus {
        let curUser = try req.auth.require(User.self)
        guard curUser.isAdmin else {
            throw UserError.userNotAdmin
        }

        guard let instructorId = req.parameters.get(Self.instructorIdParam, as: UUID.self) else {
            throw Self.missingInstructorIdError
        }
        guard let stationId = req.parameters.get(Self.stationIdParam, as: UUID.self) else {
            throw Self.missingStationIdError
        }

        try await req.instructorService.deleteInstructor(userId: instructorId, stationId: stationId)
        return .noContent
    }
}
