// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "FourCorners",
    platforms: [.macOS(.v11), .iOS(.v14), .tvOS(.v14)],
    products: [
        .library( name: "FourCorners", targets: ["FourCorners"])
    ],
    dependencies: [
        .package( url: "https://github.com/iStumblerLabs/KitBridge.git", from: "1.3.2")
    ],
    targets: [
        .target( name: "FourCorners", dependencies: ["KitBridge"])
    ]
)
