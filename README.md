# SIWE-Swift - A lightweight SIWE (Sign-In With Ethereum) Library for your Server-Side Swift Application

SIWE-Swift helps you integrate Web3 authentication (MetaMask, WalletConnect, any other wallet which supports EIP-4361) into your Web app.
Smart contracts (EIP-1271) are not supported, as it would require interacting with the network

## Description
This is a light version of elegant library [web3.swift](https://github.com/argentlabs/web3.swift) to only validate and verify SIWE messages for your Server-Side Swift application.

## Usage example
Add it to your App:

```swift
.package(url: "https://github.com/bigvo/siwe-swift.git", from: "0.0.1"),
```

import with

```swift
import SIWE
```

Use with your Vapor app:

```swift
        let signedMessage = try req.content.decode(SignedMessage.self)

        let message = try SIWEMessage.init(signedMessage.message)
        
        guard user.nonce == Int(message.nonce) &&
                user.address == message.address &&
                domain == message.domain
                else { throw Abort(.unauthorized, reason: "Nice try") }
                
        // MARK: Update nonce after successful login
        if try await siweVerifier.verify(message: message, against: signedMessage.signature) {
            user.nonce = Int.random(in: 10000000 ... 99999999)
            try await user.save(on: req.db)
            req.auth.login(user)
            return Response(status: .noContent)
        }
```

- Important: Nonce should be at least 8 alphabet letters or digits
