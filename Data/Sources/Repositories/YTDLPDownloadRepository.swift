import Foundation
import Domain

/// yt-dlp 프로세스를 id별로 관리한다. pause는 SIGTERM으로 종료만 하고,
/// 이후 같은 id로 start를 다시 호출하면 yt-dlp 기본 옵션(--continue)이 이어받기를 처리한다.
public final class YTDLPDownloadRepository: DownloadRepository {
    private var processes: [UUID: Process] = [:]
    private let queue = DispatchQueue(label: "YTDLPDownloadRepository")

    public init() {}

    public func start(
        id: UUID,
        url: String,
        formatId: String?,
        outputDirectory: String,
        onProgress: @escaping (Double, String, String) -> Void,
        onFinish: @escaping (DownloadOutcome) -> Void
    ) {
        guard let bin = BinaryManager.ytDlpPath else {
            onFinish(.failed(YTDLPError.binaryNotFound.localizedDescription))
            return
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: bin)

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

        process.terminationHandler = { [weak self] proc in
            self?.queue.async {
                self?.processes.removeValue(forKey: id)
            }
            DispatchQueue.main.async {
                if proc.terminationStatus == 0 {
                    onFinish(.completed)
                } else {
                    onFinish(.terminatedByClient)
                }
            }
        }

        queue.sync { processes[id] = process }

        do {
            try process.run()
        } catch {
            queue.async { self.processes.removeValue(forKey: id) }
            onFinish(.failed(error.localizedDescription))
        }
    }

    public func pause(id: UUID) {
        queue.sync { processes[id] }?.terminate()
    }

    public func cancel(id: UUID) {
        queue.sync { processes[id] }?.terminate()
    }
}
