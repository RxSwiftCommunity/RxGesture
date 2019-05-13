// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "RxGesture",
    products: [
        .library(name: "RxGesture", targets: ["RxGesture"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0")),
    ],
    targets: [
        .target(
            name: "RxGesture",
            dependencies: ["RxSwift", "RxCocoa"],
            path: "Pod",
            exclude: ["Pod/Classes/OSX"]
        )
    ]
)
