// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "RxGesture",
    products: [
        .library(name: "RxGesture", targets: ["RxGesture"])
    ],
    dependencies: [
        .package(url: "https://git.maxjia.com/heybox_ios/RxSwift.git", revision: "fd4c2c6b6c9569583a731238ed44dec34bfd2677"),
    ],
    targets: [
        .target(
            name: "RxGesture",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift")
            ],
            path: "Pod",
            exclude: ["Classes/OSX"]
        )
    ]
)
