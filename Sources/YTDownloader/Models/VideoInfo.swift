import Foundation

struct VideoInfo: Decodable, Identifiable {
    let id: String
    let title: String
    let thumbnail: String?
    let duration: Double?
    let uploader: String?
    let formats: [VideoFormat]

    enum CodingKeys: String, CodingKey {
        case id, title, thumbnail, duration, uploader, formats
    }
}

struct VideoFormat: Decodable, Identifiable, Hashable {
    let formatId: String
    let ext: String
    let resolution: String?
    let fps: Double?
    let vcodec: String?
    let acodec: String?
    let filesize: Int64?
    let formatNote: String?
    let tbr: Double?

    var id: String { formatId }

    enum CodingKeys: String, CodingKey {
        case formatId = "format_id"
        case ext
        case resolution
        case fps
        case vcodec
        case acodec
        case filesize
        case formatNote = "format_note"
        case tbr
    }

    var hasVideo: Bool { vcodec != nil && vcodec != "none" }
    var hasAudio: Bool { acodec != nil && acodec != "none" }

    var displayLabel: String {
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
