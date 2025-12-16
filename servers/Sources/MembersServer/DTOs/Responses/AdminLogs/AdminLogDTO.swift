import Foundation
import Vapor

struct AdminLogDTO: Content, Codable {
    let id: UUID
    let user: UserSummaryResponseDTO
    let log: String
}

extension AdminLog {
    func toDTO() throws -> AdminLogDTO {
        guard let id else {
            throw ServerError.unexpectedError(reason: "Log missing id")
        }
        return AdminLogDTO(
            id: id,
            user: try self.user.toSummaryDTO(),
            log: self.log
        )
    }
}
