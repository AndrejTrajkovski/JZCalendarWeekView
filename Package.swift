// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JZCalendarWeekView",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "JZCalendarWeekView",
            targets: ["JZCalendarWeekView"])
    ],
    dependencies: [
		.package(url: "../Util",
						 from: Version.init(stringLiteral: "1.0.0"))
    ],
    targets: [
        .target(
            name: "JZCalendarWeekView",
            dependencies: ["Util"],
            path: "JZCalendarWeekView")
    ]
)
