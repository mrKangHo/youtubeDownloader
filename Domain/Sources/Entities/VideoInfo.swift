import Foundation

public struct VideoInfo: Equatable {
    public let id: String
    public let title: String
    public let thumbnailURL: URL?
    public let duration: Double?
    public let uploader: String?
    public let formats: [VideoFormat]

    public init(id: String, title: String, thumbnailURL: URL?, duration: Double?, uploader: String?, formats: [VideoFormat]) {
        self.id = id
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.duration = duration
        self.uploader = uploader
        self.formats = formats
    }
}

public struct VideoFormat: Equatable, Hashable, Identifiable {
    public let formatId: String
    public let ext: String
    public let resolution: String?
    public let fps: Double?
    public let vcodec: String?
    public let acodec: String?
    public let filesize: Int64?
    public let formatNote: String?
    public let tbr: Double?

    public var id: String { formatId }

    public init(
        formatId: String,
        ext: String,
        resolution: String?,
        fps: Double?,
        vcodec: String?,
        acodec: String?,
        filesize: Int64?,
        formatNote: String?,
        tbr: Double?
    ) {
        self.formatId = formatId
        self.ext = ext
        self.resolution = resolution
        self.fps = fps
        self.vcodec = vcodec
        self.acodec = acodec
        self.filesize = filesize
        self.formatNote = formatNote
        self.tbr = tbr
    }

    public var hasVideo: Bool { vcodec != nil && vcodec != "none" }
    public var hasAudio: Bool { acodec != nil && acodec != "none" }

    public var displayLabel: String {
        var parts: [String] = []
        if let resolution, resolution != "audio only" {
            parts.append(resolution)
        } else if !hasVideo {
            parts.append("audio only")
        }
        if let formatNote, !formatNote.isEmpty {
            parts.append(formatNote)
        }
        parts.append(ext)
        if !hasVideo {
            parts.append("audio")
        } else if !hasAudio {
            parts.append("video only")
        }
        if let filesize {
            parts.append(ByteCountFormatter.string(fromByteCount: filesize, countStyle: .file))
        }
        return parts.joined(separator: " · ")
    }
}
