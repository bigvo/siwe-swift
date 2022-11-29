import Foundation

extension SIWEMessage: CustomStringConvertible {

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return formatter
    }()

    /// `SIWEMessage` can be easily converted into a SIWE string message simply by using this property (which in turn is also
    /// used natively when doing `"\(message)"`)
    ///
    /// The SIWE string message follows [EIP-4361](https://eips.ethereum.org/EIPS/eip-4361), and looks something like the following:
    ///
    /// ```
    /// service.org wants you to sign in with your Ethereum account:
    /// 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    ///
    /// I accept the ServiceOrg Terms of Service: https://service.org/tos
    ///
    /// URI: https://service.org/login
    /// Version: 1
    /// Chain ID: 1
    /// Nonce: 32891756
    /// Issued At: 2021-09-30T16:25:24Z
    /// Resources:
    /// - ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/
    /// - https://example.com/my-web2-claim.json
    /// ```
    public var description: String {
        var fields = [
            "\(domain) wants you to sign in with your Ethereum account:",
            "\(address)",
            "\(statement.map { "\n\($0)\n" } ?? "\n")",
            "URI: \(uri.absoluteString)",
            "Version: \(version)",
            "Chain ID: \(chainId)",
            "Nonce: \(nonce)",
            "Issued At: \(SIWEMessage.dateFormatter.string(from: issuedAt))"
        ]

        if let expirationTime = expirationTime {
            fields.append("Expiration Time: \(SIWEMessage.dateFormatter.string(from: expirationTime))")
        }
        if let notBefore = notBefore {
            fields.append("Not Before: \(SIWEMessage.dateFormatter.string(from: notBefore))")
        }
        if let requestId = requestId {
            fields.append("Request ID: \(requestId)")
        }
        if let resources = resources {
            fields.append("Resources:")
            fields.append(contentsOf: resources.map { "- \($0.absoluteString)" })
        }

        return fields.joined(separator: "\n")
    }

    /// `SIWEMessage` can easily be created from a SIWE string message
    ///
    /// The SIWE string message follows [EIP-4361](https://eips.ethereum.org/EIPS/eip-4361), and looks something like the following:
    ///
    /// ```
    /// service.org wants you to sign in with your Ethereum account:
    /// 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    ///
    /// I accept the ServiceOrg Terms of Service: https://service.org/tos
    ///
    /// URI: https://service.org/login
    /// Version: 1
    /// Chain ID: 1
    /// Nonce: 32891756
    /// Issued At: 2021-09-30T16:25:24Z
    /// Resources:
    /// - ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/
    /// - https://example.com/my-web2-claim.json
    /// ```
    /// - Parameter description: the SIWE string message following EIP-4361 standard.
    /// - Throws: `SIWEMessage.RegExError` if an error occured while parsing the string;
    ///           `SIWEMessage.ValidationError` in case regex parsing was successful but data in the message was invalid;
    ///           might throw `DecodingError` since we use `Decodable` to transform parsed values into `SIWEMessage`.
    @available(macOS 10.13, *)
    public init(_ description: String) throws {
        try self.init(fromStringUsingRegEx: description)
    }
}
