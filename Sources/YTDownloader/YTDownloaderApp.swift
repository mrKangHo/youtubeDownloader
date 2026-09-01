import SwiftUI

@main
struct YTDownloaderApp: App {
    @StateObject private var manager = DownloadManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(manager)
        }
        .windowResizability(.contentSize)
    }
}
