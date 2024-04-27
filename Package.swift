// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SIWE",
    products: [
        .library(
            name: "SIWE",
            targets: ["SIWE"]),
    ],
    dependencies: [
        .package(url: "https://github.com/attaswift/BigInt", from: "5.0.0"),
        .package(url: "https://github.com/GigaBitcoin/secp256k1.swift.git", .exact("0.10.0")),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SIWE",
            dependencies: [
                .product(name: "BigInt", package: "BigInt"),
                .target(name: "keccaktiny"),
                .product(name: "secp256k1", package: "secp256k1.swift"),
                .product(name: "Logging", package: "swift-log"),
            ],
            path: "SIWE/src"),
        .target(
            name: "keccaktiny",
            dependencies: [],
            path: "SIWE/lib/keccak-tiny",
            exclude: ["module.map"]
        ),
    ]
)
