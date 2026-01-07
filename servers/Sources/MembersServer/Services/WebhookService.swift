import Crypto
import Foundation
import Vapor

struct WebhookService {
    private let client: any Client
    private let logger: Logger
    private let webhookURL: String?
    private let webhookSecret: String?

    init(client: any Client, logger: Logger, webhookURL: String?, webhookSecret: String?) {
        self.client = client
        self.logger = logger
        self.webhookURL = webhookURL
        self.webhookSecret = webhookSecret
    }

    func sendMemberRegisteredWebhook(for user: User) async {
        guard let webhookURL, !webhookURL.isEmpty else {
            logger.debug("Webhook URL not configured, skipping member registration webhook")
            return
        }

        guard let userId = user.id?.uuidString else {
            logger.warning("Cannot send member registration webhook: user ID is nil")
            return
        }

        let payload = MemberRegisteredPayload(
            event: "member.registered",
            timestamp: ISO8601DateFormatter().string(from: Date()),
            data: MemberRegisteredPayload.MemberData(
                id: userId,
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
                membershipLevel: user.membershipLevel?.$membershipLevel.value?.name
            )
        )

        do {
            let jsonData = try JSONEncoder().encode(payload)
            let signature = generateSignature(for: jsonData)

            var headers = HTTPHeaders()
            headers.add(name: .contentType, value: "application/json")
            if let signature {
                headers.add(name: "X-Webhook-Signature", value: signature)
            }

            let response = try await client.post(URI(string: webhookURL), headers: headers) { req in
                req.timeout = .seconds(10)
                req.body = ByteBuffer(data: jsonData)
            }

            if response.status.code >= 200 && response.status.code < 300 {
                logger.info("Member registration webhook sent successfully for user \(userId)")
            } else {
                logger.warning("Member registration webhook returned non-success status: \(response.status)")
            }
        } catch {
            logger.error("Failed to send member registration webhook: \(error)")
        }
    }

    private func generateSignature(for data: Data) -> String? {
        guard let webhookSecret, !webhookSecret.isEmpty else {
            logger.debug("Webhook secret not configured, skipping signature")
            return nil
        }

        let key = SymmetricKey(data: Data(webhookSecret.utf8))
        let signature = HMAC<SHA256>.authenticationCode(for: data, using: key)
        return "sha256=" + Data(signature).map { String(format: "%02x", $0) }.joined()
    }
}

struct MemberRegisteredPayload: Codable {
    let event: String
    let timestamp: String
    let data: MemberData

    struct MemberData: Codable {
        let id: String
        let firstName: String
        let lastName: String
        let email: String
        let membershipLevel: String?
    }
}
