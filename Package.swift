// swift-tools-version:5.0.0
import PackageDescription

let package = Package(
    name: "rds-data",
    products: [
        .library(name: "RDSData", targets: ["RDSData"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-aws/aws-sdk-swift.git", .upToNextMinor(from: "3.5.1"))
    ],
    targets: [
        .target(
            name: "RDSData",
            dependencies: [
                "RDSDataService"
            ]
        ),
        .testTarget(
            name: "RDSDataTests",
            dependencies: [
                "RDSData"
            ]
        )
    ]
)
