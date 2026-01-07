import Crypto
import Foundation
import Testing

@testable import MembersServer

@Suite("WebhookService Tests")
struct WebhookServiceTests {
    @Test("Test HMAC signature generation")
    func testSignatureGeneration() async throws {
        let payload = MemberRegisteredPayload(
            event: "member.registered",
            timestamp: "2024-01-01T00:00:00Z",
            data: MemberRegisteredPayload.MemberData(
                id: "test-uuid",
                firstName: "John",
                lastName: "Doe",
                email: "john@example.com",
                membershipLevel: "Basic"
            )
        )

        let jsonData = try JSONEncoder().encode(payload)
        let secret = "test-secret-key"

        let key = SymmetricKey(data: Data(secret.utf8))
        let signature = HMAC<SHA256>.authenticationCode(for: jsonData, using: key)
        let signatureHex = "sha256=" + Data(signature).map { String(format: "%02x", $0) }.joined()

        #expect(signatureHex.hasPrefix("sha256="))
        #expect(signatureHex.count == 71)  // "sha256=" (7) + 64 hex chars
    }

    @Test("Test payload encoding")
    func testPayloadEncoding() async throws {
        let payload = MemberRegisteredPayload(
            event: "member.registered",
            timestamp: "2024-01-01T00:00:00Z",
            data: MemberRegisteredPayload.MemberData(
                id: "123e4567-e89b-12d3-a456-426614174000",
                firstName: "Jane",
                lastName: "Smith",
                email: "jane@example.com",
                membershipLevel: nil
            )
        )

        let jsonData = try JSONEncoder().encode(payload)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        #expect(jsonString.contains("member.registered"))
        #expect(jsonString.contains("Jane"))
        #expect(jsonString.contains("Smith"))
        #expect(jsonString.contains("jane@example.com"))
        #expect(jsonString.contains("123e4567-e89b-12d3-a456-426614174000"))
    }

    @Test("Test payload with membership level")
    func testPayloadWithMembershipLevel() async throws {
        let payload = MemberRegisteredPayload(
            event: "member.registered",
            timestamp: "2024-01-01T00:00:00Z",
            data: MemberRegisteredPayload.MemberData(
                id: "test-id",
                firstName: "Test",
                lastName: "User",
                email: "test@example.com",
                membershipLevel: "Premium"
            )
        )

        let jsonData = try JSONEncoder().encode(payload)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        #expect(jsonString.contains("Premium"))
    }

    @Test("Test signature verification")
    func testSignatureVerification() async throws {
        let payload = MemberRegisteredPayload(
            event: "member.registered",
            timestamp: "2024-01-01T00:00:00Z",
            data: MemberRegisteredPayload.MemberData(
                id: "verify-test",
                firstName: "Verify",
                lastName: "Test",
                email: "verify@example.com",
                membershipLevel: "Standard"
            )
        )

        let jsonData = try JSONEncoder().encode(payload)
        let secret = "webhook-secret-123"

        let key = SymmetricKey(data: Data(secret.utf8))
        let signature = HMAC<SHA256>.authenticationCode(for: jsonData, using: key)

        // Verify the signature is valid
        let isValid = HMAC<SHA256>.isValidAuthenticationCode(signature, authenticating: jsonData, using: key)
        #expect(isValid)

        // Verify modified data fails
        var modifiedData = jsonData
        modifiedData[0] = modifiedData[0] ^ 0xFF
        let isValidModified = HMAC<SHA256>.isValidAuthenticationCode(
            signature, authenticating: modifiedData, using: key)
        #expect(!isValidModified)
    }
}
