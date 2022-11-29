import BigInt
import Foundation
import keccaktiny

public protocol Web3Extendable {
    associatedtype T
    var web3: T { get }
}

public extension Web3Extendable {
    var web3: Web3Extensions<Self> {
        return Web3Extensions(self)
    }
}

public struct Web3Extensions<Base> {
    internal(set) public var base: Base
    init(_ base: Base) {
        self.base = base
    }
}

extension Data: Web3Extendable {}
extension String: Web3Extendable {}
extension BigUInt: Web3Extendable {}
extension BigInt: Web3Extendable {}
extension Int: Web3Extendable {}

public extension Web3Extensions where Base == String {
    var noHexPrefix: String {
        if base.hasPrefix("0x") {
            let index = base.index(base.startIndex, offsetBy: 2)
            return String(base[index...])
        }
        return base
    }
    
    var keccak256: Data {
        let data = base.data(using: .utf8) ?? Data()
        return data.web3.keccak256
    }
    
    var hexData: Data? {
        let noHexPrefix = self.noHexPrefix
        if let bytes = try? HexUtil.byteArray(fromHex: noHexPrefix) {
            return Data(bytes)
        }

        return nil
    }
}

public extension Web3Extensions where Base == Data {
    var hexString: String {
        let bytes = [UInt8](base)
        return "0x" + bytes.map { String(format: "%02hhx", $0) }.joined()
    }
    
    var keccak256: Data {
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
        defer {
            result.deallocate()
        }
        let nsData = base as NSData
        let input = nsData.bytes.bindMemory(to: UInt8.self, capacity: base.count)
        keccak_256(result, 32, input, base.count)
        return Data(bytes: result, count: 32)
    }
}
