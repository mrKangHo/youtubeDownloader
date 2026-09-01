import Foundation
import Domain

public enum YTDLPError: LocalizedError {
    case binaryNotFound
    case processFailed(String)
    case decodeFailed

    public var errorDescription: String? {
        switch self {
        case .binaryNotFound:
            return String(localized: "yt-dlp executable not found. Install it with Homebrew: brew install yt-dlp", bundle: .main)
        case .processFailed(let message):
            return message
        case .decodeFailed:
            return String(localized: "Failed to parse video information.", bundle: .main)
        }
    }
}

public final class YTDLPVideoInfoRepository: VideoInfoRepository {
    public init() {}

    public func fetchInfo(url: String) async throws -> VideoInfo {
        guard let bin = BinaryManager.ytDlpPath else { throw YTDLPError.binaryNotFound }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: bin)
        process.arguments = ["-J", "--no-playlist", url]
        if let ffmpegDir = BinaryManager.ffmpegDirectory {
            var env = ProcessInfo.processInfo.environment
            env["PATH"] = "\(ffmpegDir):" + (env["PATH"] ?? "")
            process.environment = env
        }

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        try process.run()

        let stdoutData = try stdoutPipe.fileHandleForReading.readToEnd() ?? Data()
        let stderrData = try stderrPipe.fileHandleForReading.readToEnd() ?? Data()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let message = String(data: stderrData, encoding: .utf8) ?? String(localized: "yt-dlp execution failed", bundle: .main)
            throw YTDLPError.processFailed(message)
        }

        do {
            return try JSONDecoder().decode(YTDLPVideoInfoDTO.self, from: stdoutData).toDomain()
        } catch {
            throw YTDLPError.decodeFailed
        }
    }
}
