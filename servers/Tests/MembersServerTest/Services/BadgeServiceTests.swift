import Fluent
import Testing
import VaporTesting

@testable import MembersServer

@Suite("BadgeService Tests with DB", .serialized)
struct BadgeServiceTests {
    private static func sampleStation(name: String = "Test Station") -> Station {
        Station(name: name)
    }

    private static func sampleBadgeDTO(name: String = "Test Badge", stationId: UUID) -> BadgeRequestDTO {
        BadgeRequestDTO(
            name: name,
            description: "Test badge description",
            imageURL: "https://example.com/badge.png",
            stationId: stationId
        )
    }

    @Test("Test Add Badge")
    func testAddBadge() async throws {
        try await withApp { app in
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let station = Self.sampleStation()
            try await station.save(on: app.db)
            guard let stationId = station.id else {
                #expect(Bool(false), "Station ID was nil")
                return
            }

            let badgeDTO = Self.sampleBadgeDTO(stationId: stationId)
            let createdBadge = try await badgeService.addBadge(from: badgeDTO)

            #expect(createdBadge.name == badgeDTO.name)
            #expect(createdBadge.description == badgeDTO.description)
            #expect(createdBadge.imageURL == badgeDTO.imageURL)
            #expect(createdBadge.station.id == stationId)
        }
    }

    @Test("Test Get Badge")
    func testGetBadge() async throws {
        try await withApp { app in
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let station = Self.sampleStation()
            try await station.save(on: app.db)
            guard let stationId = station.id else {
                #expect(Bool(false), "Station ID was nil")
                return
            }

            let badgeDTO = Self.sampleBadgeDTO(stationId: stationId)
            let createdBadge = try await badgeService.addBadge(from: badgeDTO)

            let fetchedBadge = try await badgeService.getBadge(for: createdBadge.id)
            guard let fetchedBadge else {
                #expect(Bool(false), "Fetched badge was nil")
                return
            }

            #expect(fetchedBadge.id == createdBadge.id)
            #expect(fetchedBadge.name == createdBadge.name)
            #expect(fetchedBadge.description == createdBadge.description)
            #expect(fetchedBadge.station.id == stationId)
        }
    }

    @Test("Test Get Non-Existent Badge Returns Nil")
    func testGetNonExistentBadge() async throws {
        try await withApp { app in
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let fetchedBadge = try await badgeService.getBadge(for: UUID())
            #expect(fetchedBadge == nil)
        }
    }

    @Test("Test Get All Badges")
    func testGetAllBadges() async throws {
        try await withApp { app in
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let station1 = Self.sampleStation(name: "Station 1")
            let station2 = Self.sampleStation(name: "Station 2")
            let station3 = Self.sampleStation(name: "Station 3")
            try await [station1, station2, station3].create(on: app.db)

            let badgeDTO1 = Self.sampleBadgeDTO(name: "Badge 1", stationId: station1.id!)
            let badgeDTO2 = Self.sampleBadgeDTO(name: "Badge 2", stationId: station2.id!)
            let badgeDTO3 = Self.sampleBadgeDTO(name: "Badge 3", stationId: station3.id!)

            _ = try await badgeService.addBadge(from: badgeDTO1)
            _ = try await badgeService.addBadge(from: badgeDTO2)
            _ = try await badgeService.addBadge(from: badgeDTO3)

            let allBadges = try await badgeService.getAllBadges()
            #expect(allBadges.count == 3)
        }
    }

    @Test("Test Update Badge")
    func testUpdateBadge() async throws {
        try await withApp { app in
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let station = Self.sampleStation()
            try await station.save(on: app.db)
            guard let stationId = station.id else {
                #expect(Bool(false), "Station ID was nil")
                return
            }

            let badgeDTO = Self.sampleBadgeDTO(stationId: stationId)
            let createdBadge = try await badgeService.addBadge(from: badgeDTO)

            let updateDTO = BadgeRequestDTO(
                name: badgeDTO.name,
                description: "Updated description",
                imageURL: "https://example.com/updated.png",
                stationId: stationId
            )

            let updatedBadge = try await badgeService.updateBadge(from: updateDTO, for: createdBadge.id)

            #expect(updatedBadge.name == badgeDTO.name)
            #expect(updatedBadge.description == "Updated description")
            #expect(updatedBadge.imageURL == "https://example.com/updated.png")
        }
    }

    @Test("Update Non-Existent Badge Throws Error")
    func testUpdateNonExistentBadge() async throws {
        try await withApp { app in
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let station = Self.sampleStation()
            try await station.save(on: app.db)
            guard let stationId = station.id else {
                #expect(Bool(false), "Station ID was nil")
                return
            }

            await #expect(throws: BadgeError.badgeNotFound) {
                let updateDTO = Self.sampleBadgeDTO(stationId: stationId)
                _ = try await badgeService.updateBadge(from: updateDTO, for: UUID())
            }
        }
    }

    @Test("Test Delete Badge")
    func testDeleteBadge() async throws {
        try await withApp { app in
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let station = Self.sampleStation()
            try await station.save(on: app.db)
            guard let stationId = station.id else {
                #expect(Bool(false), "Station ID was nil")
                return
            }

            let badgeDTO = Self.sampleBadgeDTO(stationId: stationId)
            let createdBadge = try await badgeService.addBadge(from: badgeDTO)

            try await badgeService.deleteBadge(id: createdBadge.id)

            let found = try await Badge.find(createdBadge.id, on: app.db)
            #expect(found == nil)
        }
    }

    @Test("Add Badge With Duplicate Name Throws Error")
    func testAddBadgeWithDuplicateName() async throws {
        try await withApp { app in
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let station1 = Self.sampleStation(name: "Station 1")
            let station2 = Self.sampleStation(name: "Station 2")
            try await [station1, station2].create(on: app.db)

            let badgeDTO1 = Self.sampleBadgeDTO(name: "Duplicate Name", stationId: station1.id!)
            _ = try await badgeService.addBadge(from: badgeDTO1)

            await #expect(throws: BadgeError.uniqueViolation(field: .name)) {
                let badgeDTO2 = Self.sampleBadgeDTO(name: "Duplicate Name", stationId: station2.id!)
                _ = try await badgeService.addBadge(from: badgeDTO2)
            }
        }
    }

    @Test("Add Badge With Duplicate Station Throws Error")
    func testAddBadgeWithDuplicateStation() async throws {
        try await withApp { app in
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let station = Self.sampleStation()
            try await station.save(on: app.db)
            guard let stationId = station.id else {
                #expect(Bool(false), "Station ID was nil")
                return
            }

            let badgeDTO1 = Self.sampleBadgeDTO(name: "Badge 1", stationId: stationId)
            _ = try await badgeService.addBadge(from: badgeDTO1)

            await #expect(throws: BadgeError.uniqueViolation(field: .station)) {
                let badgeDTO2 = Self.sampleBadgeDTO(name: "Badge 2", stationId: stationId)
                _ = try await badgeService.addBadge(from: badgeDTO2)
            }
        }
    }

    @Test("Update Badge With Duplicate Name Throws Error")
    func testUpdateBadgeWithDuplicateName() async throws {
        try await withApp { app in
            let badgeService = BadgeService(database: app.db, logger: app.logger)

            let station1 = Self.sampleStation(name: "Station 1")
            let station2 = Self.sampleStation(name: "Station 2")
            try await [station1, station2].create(on: app.db)

            let badgeDTO1 = Self.sampleBadgeDTO(name: "Badge 1", stationId: station1.id!)
            let badgeDTO2 = Self.sampleBadgeDTO(name: "Badge 2", stationId: station2.id!)

            _ = try await badgeService.addBadge(from: badgeDTO1)
            let badge2 = try await badgeService.addBadge(from: badgeDTO2)

            await #expect(throws: BadgeError.uniqueViolation(field: .name)) {
                let updateDTO = BadgeRequestDTO(
                    name: "Badge 1",
                    description: "Updated description",
                    imageURL: nil,
                    stationId: station2.id!
                )
                _ = try await badgeService.updateBadge(from: updateDTO, for: badge2.id)
            }
        }
    }
}
