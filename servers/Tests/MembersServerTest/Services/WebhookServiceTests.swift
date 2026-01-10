import Crypto
import Foundation
import Logging
import Testing
import VaporTesting

@testable import MembersServer

@Suite("WebhookService Tests")
struct WebhookServiceTests {
    private static func createMockLogger() -> Logger {
        Logger(label: "test.webhook")
    }

    @Test("Service generates correct HMAC-SHA256 signature")
    func testServiceGeneratesSignature() async throws {
        try await withApp { app in
            let secret = "test-secret-key"
            let service = WebhookService(
                client: app.client,
                logger: Self.createMockLogger(),
                webhookURL: "https://example.com/webhook",
                webhookSecret: secret
            )

            let testData = Data("test payload".utf8)
            let signature = service.generateSignature(for: testData)

            #expect(signature != nil)
            #expect(signature!.hasPrefix("sha256="))
            #expect(signature!.count == 71)  // "sha256=" (7) + 64 hex chars

            // Verify the signature matches expected HMAC-SHA256
            let key = SymmetricKey(data: Data(secret.utf8))
            let expectedMAC = HMAC<SHA256>.authenticationCode(for: testData, using: key)
            let expectedSignature = "sha256=" + Data(expectedMAC).map { String(format: "%02x", $0) }.joined()
            #expect(signature == expectedSignature)
        }
    }

    @Test("Service returns nil signature when secret is not configured")
    func testNoSignatureWithoutSecret() async throws {
        try await withApp { app in
            let service = WebhookService(
                client: app.client,
                logger: Self.createMockLogger(),
                webhookURL: "https://example.com/webhook",
                webhookSecret: nil
            )

            let testData = Data("test payload".utf8)
            let signature = service.generateSignature(for: testData)

            #expect(signature == nil)
        }
    }

    @Test("Service returns nil signature when secret is empty")
    func testNoSignatureWithEmptySecret() async throws {
        try await withApp { app in
            let service = WebhookService(
                client: app.client,
                logger: Self.createMockLogger(),
                webhookURL: "https://example.com/webhook",
                webhookSecret: ""
            )

            let testData = Data("test payload".utf8)
            let signature = service.generateSignature(for: testData)

            #expect(signature == nil)
        }
    }

    @Test("Different payloads produce different signatures")
    func testDifferentPayloadsDifferentSignatures() async throws {
        try await withApp { app in
            let service = WebhookService(
                client: app.client,
                logger: Self.createMockLogger(),
                webhookURL: "https://example.com/webhook",
                webhookSecret: "secret"
            )

            let signature1 = service.generateSignature(for: Data("payload1".utf8))
            let signature2 = service.generateSignature(for: Data("payload2".utf8))

            #expect(signature1 != nil)
            #expect(signature2 != nil)
            #expect(signature1 != signature2)
        }
    }

    @Test("Different secrets produce different signatures")
    func testDifferentSecretsDifferentSignatures() async throws {
        try await withApp { app in
            let service1 = WebhookService(
                client: app.client,
                logger: Self.createMockLogger(),
                webhookURL: "https://example.com/webhook",
                webhookSecret: "secret1"
            )
            let service2 = WebhookService(
                client: app.client,
                logger: Self.createMockLogger(),
                webhookURL: "https://example.com/webhook",
                webhookSecret: "secret2"
            )

            let testData = Data("same payload".utf8)
            let signature1 = service1.generateSignature(for: testData)
            let signature2 = service2.generateSignature(for: testData)

            #expect(signature1 != nil)
            #expect(signature2 != nil)
            #expect(signature1 != signature2)
        }
    }

    @Test("Signature can be verified by receiver")
    func testSignatureVerification() async throws {
        try await withApp { app in
            let secret = "webhook-secret-123"
            let service = WebhookService(
                client: app.client,
                logger: Self.createMockLogger(),
                webhookURL: "https://example.com/webhook",
                webhookSecret: secret
            )

            let payload = MemberRegisteredPayload(
                event: "member.registered",
                timestamp: "2024-01-01T00:00:00Z",
                data: MemberRegisteredPayload.MemberData(
                    id: "test-uuid",
                    firstName: "Test",
                    lastName: "User",
                    email: "test@example.com",
                    membershipLevel: "Basic"
                )
            )

            let jsonData = try JSONEncoder().encode(payload)
            let signature = service.generateSignature(for: jsonData)

            #expect(signature != nil)

            // Simulate receiver verification
            let receivedSignatureHex = String(signature!.dropFirst(7))  // Remove "sha256=" prefix
            let receivedSignatureData = Data(hexString: receivedSignatureHex)!

            let key = SymmetricKey(data: Data(secret.utf8))
            let isValid = HMAC<SHA256>.isValidAuthenticationCode(
                receivedSignatureData,
                authenticating: jsonData,
                using: key
            )
            #expect(isValid)
        }
    }

    @Test("Payload encoding includes all required fields")
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

    @Test("Payload encoding includes membership level when present")
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
}

extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var index = hexString.startIndex
        for _ in 0..<len {
            let nextIndex = hexString.index(index, offsetBy: 2)
            guard let byte = UInt8(hexString[index..<nextIndex], radix: 16) else {
                return nil
            }
            data.append(byte)
            index = nextIndex
        }
        self = data
    }
}
