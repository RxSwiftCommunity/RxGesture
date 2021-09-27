// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "RxGesture",
    products: [
        .library(name: "RxGesture", targets: ["RxGesture"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.0.0")),
    ],
    targets: [
        .target(
            name: "RxGesture",
            dependencies: ["RxSwift", "RxCocoa"],
            path: "Pod",
            exclude: ["Classes/OSX"]
        )
    ]
)
