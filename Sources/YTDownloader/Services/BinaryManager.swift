import Foundation

enum BinaryManager {
    static let candidatePaths = [
        "/opt/homebrew/bin/yt-dlp",
        "/usr/local/bin/yt-dlp",
        "/usr/bin/yt-dlp"
    ]

    static var ytDlpPath: String? {
        if let bundled = Bundle.main.path(forResource: "yt-dlp", ofType: nil) {
            return bundled
        }
        for path in candidatePaths where FileManager.default.isExecutableFile(atPath: path) {
            return path
        }
        return nil
    }

    static var ffmpegDirectory: String? {
        let candidates = ["/opt/homebrew/bin", "/usr/local/bin"]
        for dir in candidates where FileManager.default.isExecutableFile(atPath: dir + "/ffmpeg") {
            return dir
        }
        return nil
    }

    static var isAvailable: Bool { ytDlpPath != nil }
}
