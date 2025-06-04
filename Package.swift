// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AIDream",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AIDream",
            targets: ["AIDream"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "2.3.1"),
        .package(url: "https://github.com/superwall-me/Superwall-iOS.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "AIDream",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "SuperwallKit", package: "Superwall-iOS")
            ]),
        .testTarget(
            name: "AIDreamTests",
            dependencies: ["AIDream"]),
    ]
) 