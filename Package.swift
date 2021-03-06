// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftAnnouncements",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v8),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftAnnouncements",
            targets: ["SwiftAnnouncements"]),
    ],
    dependencies: [
        .package(name: "Nimble", url: "https://github.com/Quick/Nimble", from: "9.2.0"),
        .package(name: "RWLock", url: "https://github.com/grype/RWLock-Swift", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftAnnouncements",
            dependencies: ["RWLock"]),
        .testTarget(
            name: "SwiftAnnouncementsTests",
            dependencies: ["SwiftAnnouncements", "Nimble"]),
    ]
)
