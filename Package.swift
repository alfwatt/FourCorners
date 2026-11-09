// swift-tools-version:6.2

import Foundation
import PackageDescription

// Uses a local sibling checkout if one is present (development), otherwise
// falls back to the git remote (CI, or anyone who hasn't checked it out locally).
func localOrRemote(_ name: String, url: String, from version: Version) -> Package.Dependency {
    let packageDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    let localPath = packageDirectory.deletingLastPathComponent().appendingPathComponent(name).path
    if FileManager.default.fileExists(atPath: localPath) {
        return .package(path: localPath)
    }
    return .package(url: url, from: version)
}

let package = Package(
    name: "FourCorners",
    platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v17), .watchOS(.v10), .visionOS(.v26)],
    products: [
        .library(name: "FourCorners", targets: ["FourCorners"])
    ],
    dependencies: [
        localOrRemote("KitBridge", url: "https://github.com/alfwatt/KitBridge.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "FourCorners", dependencies: ["KitBridge"]),
        .testTarget(name: "FourCornersTests", dependencies: ["FourCorners"])
    ]
)
