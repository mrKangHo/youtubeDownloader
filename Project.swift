import ProjectDescription

let bundleIdPrefix = "com.coke8707.YTDownloader"
let deploymentTargets: DeploymentTargets = .macOS("14.0")

func moduleTarget(_ name: String, dependencies: [TargetDependency] = []) -> Target {
    .target(
        name: name,
        destinations: .macOS,
        product: .staticFramework,
        bundleId: "\(bundleIdPrefix).\(name)",
        deploymentTargets: deploymentTargets,
        infoPlist: .default,
        buildableFolders: [
            .folder(Path("\(name)/Sources"))
        ],
        dependencies: dependencies
    )
}

let project = Project(
    name: "YTDownloader",
    targets: [
        moduleTarget("Domain"),
        moduleTarget("Data", dependencies: [.target(name: "Domain")]),
        moduleTarget("Presentation", dependencies: [.target(name: "Domain")]),
        .target(
            name: "YTDownloader",
            destinations: .macOS,
            product: .app,
            bundleId: bundleIdPrefix,
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "YTDownloader",
                    "CFBundleShortVersionString": "1.0",
                    "CFBundleVersion": "1",
                    "LSMinimumSystemVersion": "14.0",
                    "LSApplicationCategoryType": "public.app-category.utilities",
                    "NSHumanReadableCopyright": "",
                ]
            ),
            buildableFolders: [
                .folder(Path("App/Sources"))
            ],
            entitlements: .file(path: "App/YTDownloader.entitlements"),
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Data"),
                .target(name: "Presentation"),
            ]
        ),
    ]
)
