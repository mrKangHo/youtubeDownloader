import Foundation

enum YTDLPError: LocalizedError {
    case binaryNotFound
    case processFailed(String)
    case decodeFailed

    var errorDescription: String? {
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

struct YTDLPService {
    static func fetchInfo(url: String) async throws -> VideoInfo {
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
            return try JSONDecoder().decode(VideoInfo.self, from: stdoutData)
        } catch {
            throw YTDLPError.decodeFailed
        }
    }

    /// progress line format emitted via --progress-template, e.g. "PROGRESS|42.5|1.2MiB/s|00:12"
    static func download(
        url: String,
        formatId: String?,
        outputDirectory: String,
        onProgress: @escaping (Double, String, String) -> Void
    ) -> Process {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: BinaryManager.ytDlpPath ?? "/usr/bin/env")

        var args = ["--newline", "--no-playlist"]
        if let formatId {
            args += ["-f", "\(formatId)+bestaudio/\(formatId)"]
        } else {
            args += ["-f", "bestvideo+bestaudio/best"]
        }
        args += [
            "--merge-output-format", "mp4",
            "--progress-template", "PROGRESS|%(progress._percent_str)s|%(progress._speed_str)s|%(progress._eta_str)s",
            "-o", "\(outputDirectory)/%(title)s.%(ext)s",
            url
        ]
        process.arguments = args

        if let ffmpegDir = BinaryManager.ffmpegDirectory {
            var env = ProcessInfo.processInfo.environment
            env["PATH"] = "\(ffmpegDir):" + (env["PATH"] ?? "")
            process.environment = env
        }

        let stdoutPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = Pipe()

        stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty, let line = String(data: data, encoding: .utf8) else { return }
            for rawLine in line.split(separator: "\n") {
                guard rawLine.hasPrefix("PROGRESS|") else { continue }
                let parts = rawLine.dropFirst("PROGRESS|".count).split(separator: "|", omittingEmptySubsequences: false)
                guard parts.count >= 3 else { continue }
                let percentText = parts[0].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "%", with: "")
                let percent = Double(percentText) ?? 0
                let speed = String(parts[1])
                let eta = String(parts[2])
                DispatchQueue.main.async {
                    onProgress(percent / 100.0, speed, eta)
                }
            }
        }

        return process
    }
}
