import Foundation
import Domain

public enum YTDLPError: LocalizedError {
    case binaryNotFound
    case processFailed(String)
    case decodeFailed

    public var errorDescription: String? {
        switch self {
        case .binaryNotFound:
            return "yt-dlp 실행 파일을 찾을 수 없습니다. Homebrew로 설치하세요: brew install yt-dlp"
        case .processFailed(let message):
            return message
        case .decodeFailed:
            return "영상 정보를 해석하지 못했습니다."
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
            let message = String(data: stderrData, encoding: .utf8) ?? "yt-dlp 실행 실패"
            throw YTDLPError.processFailed(message)
        }

        do {
            return try JSONDecoder().decode(YTDLPVideoInfoDTO.self, from: stdoutData).toDomain()
        } catch {
            throw YTDLPError.decodeFailed
        }
    }
}
