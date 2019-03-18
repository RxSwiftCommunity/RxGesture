// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "RxGesture",
    products: [
        .library(name: "RxGesture", targets: ["RxGesture"])
    ],
    targets: [
        .target(
            name: "RxGesture",
            path: "Pod",
            exclude: ["Pod/Classes/OSX"]
        )
    ]
)
