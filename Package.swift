// swift-tools-version:5.0.0
import PackageDescription

let package = Package(
    name: "rds-data",
    products: [
        .library(name: "RDSDataApp", targets: ["RDSDataApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-aws/aws-sdk-swift-core.git", .upToNextMinor(from: "3.1.0"))
    ],
    targets: [
        .target(
            name: "RDSDataApp",
            dependencies: [
                "RDSData"
            ]
        ),
        .target(
            name: "RDSData",
            dependencies: [
                "AWSSDKSwiftCore"
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
