// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let package = Package(
    name: "DBChainKit",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "DBChainKit",
            targets: ["DBChainKit"]),
    ],
    dependencies: [
        .package(name: "SawtoothSigning", url: "https://github.com/hyperledger/sawtooth-sdk-swift.git", .branch("main")),

        .package(name: "CryptoSwift", url: "https://github.com/krzyzanowskim/CryptoSwift.git", .branch("master")),

        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.4.3"),
    ],

    targets: [
        .target(
            name: "DBChainKit",dependencies: ["SawtoothSigning","CryptoSwift","Alamofire"],
            path: "Sources",
            publicHeadersPath: "../Sources"),
        .testTarget(
            name: "DBChainKitTests",dependencies: ["DBChainKit","SawtoothSigning","CryptoSwift","Alamofire"]),

//        .target(
//            name: "DBChainKit",dependencies: ["SawtoothSigning"],
//            path: "Sources",
//            publicHeadersPath: "../Sources"),
//        .testTarget(
//            name: "DBChainKitTests",dependencies: ["DBChainKit","SawtoothSigning"]),

    ],
    swiftLanguageVersions: [.v5]
)
