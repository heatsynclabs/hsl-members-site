import Fluent
import Testing
import VaporTesting

@testable import MembersServer

@Suite("StationService Tests with DB", .serialized)
struct StationServiceTests {
    private static func sampleStationDTO(name: String = "Test Station") -> StationRequestDTO {
        StationRequestDTO(name: name)
    }

    @Test("Test Add Station")
    func testAddStation() async throws {
        try await withApp { app in
            let stationService = StationService(database: app.db)
            let dto = Self.sampleStationDTO()
            let createdStation = try await stationService.addStation(from: dto)

            #expect(createdStation.stationName == dto.name)
            #expect(createdStation.instructors.isEmpty)
        }
    }

    @Test("Test Get Station")
    func testGetStation() async throws {
        try await withApp { app in
            let stationService = StationService(database: app.db)
            let dto = Self.sampleStationDTO()
            let createdStation = try await stationService.addStation(from: dto)

            let fetchedStation = try await stationService.getStation(createdStation.stationId)

            #expect(fetchedStation.stationId == createdStation.stationId)
            #expect(fetchedStation.stationName == createdStation.stationName)
        }
    }

    @Test("Test Get Non-Existent Station Throws Error")
    func testGetNonExistentStation() async throws {
        try await withApp { app in
            let stationService = StationService(database: app.db)

            await #expect(throws: StationError.stationNotFound) {
                _ = try await stationService.getStation(UUID())
            }
        }
    }

    @Test("Test Get All Stations")
    func testGetAllStations() async throws {
        try await withApp { app in
            let stationService = StationService(database: app.db)

            let dto1 = Self.sampleStationDTO(name: "Station 1")
            let dto2 = Self.sampleStationDTO(name: "Station 2")
            let dto3 = Self.sampleStationDTO(name: "Station 3")

            _ = try await stationService.addStation(from: dto1)
            _ = try await stationService.addStation(from: dto2)
            _ = try await stationService.addStation(from: dto3)

            let allStations = try await stationService.getStations()
            #expect(allStations.count == 3)
            #expect(allStations.map(\.name) == allStations.map(\.name).sorted())
        }
    }

    @Test("Test Update Station")
    func testUpdateStation() async throws {
        try await withApp { app in
            let stationService = StationService(database: app.db)
            let dto = Self.sampleStationDTO()
            let createdStation = try await stationService.addStation(from: dto)

            let updateDTO = StationRequestDTO(name: "Updated Station Name")
            let updatedStation = try await stationService.updateStation(from: updateDTO, for: createdStation.stationId)

            #expect(updatedStation.stationName == "Updated Station Name")
            #expect(updatedStation.stationId == createdStation.stationId)
        }
    }

    @Test("Update Non-Existent Station Throws Error")
    func testUpdateNonExistentStation() async throws {
        try await withApp { app in
            let stationService = StationService(database: app.db)
            let updateDTO = Self.sampleStationDTO()

            await #expect(throws: StationError.stationNotFound) {
                _ = try await stationService.updateStation(from: updateDTO, for: UUID())
            }
        }
    }

    @Test("Test Delete Station")
    func testDeleteStation() async throws {
        try await withApp { app in
            let stationService = StationService(database: app.db)
            let dto = Self.sampleStationDTO()
            let createdStation = try await stationService.addStation(from: dto)

            try await stationService.deleteStation(id: createdStation.stationId)

            let found = try await Station.find(createdStation.stationId, on: app.db)
            #expect(found == nil)
        }
    }

    @Test("Add Station With Duplicate Name Throws Error")
    func testAddStationWithDuplicateName() async throws {
        try await withApp { app in
            let stationService = StationService(database: app.db)
            let dto = Self.sampleStationDTO(name: "Duplicate Name")

            _ = try await stationService.addStation(from: dto)

            await #expect(throws: BadgeError.uniqueViolation(field: .name)) {
                _ = try await stationService.addStation(from: dto)
            }
        }
    }

    @Test("Update Station With Duplicate Name Throws Error")
    func testUpdateStationWithDuplicateName() async throws {
        try await withApp { app in
            let stationService = StationService(database: app.db)
            let dto1 = Self.sampleStationDTO(name: "Station 1")
            let dto2 = Self.sampleStationDTO(name: "Station 2")

            _ = try await stationService.addStation(from: dto1)
            let station2 = try await stationService.addStation(from: dto2)

            let updateDTO = StationRequestDTO(name: "Station 1")

            await #expect(throws: BadgeError.uniqueViolation(field: .name)) {
                _ = try await stationService.updateStation(from: updateDTO, for: station2.stationId)
            }
        }
    }
}
