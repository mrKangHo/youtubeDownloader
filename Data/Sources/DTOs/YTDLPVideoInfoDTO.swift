import Foundation
import Domain

struct YTDLPVideoInfoDTO: Decodable {
    let id: String
    let title: String
    let thumbnail: String?
    let duration: Double?
    let uploader: String?
    let formats: [YTDLPFormatDTO]

    func toDomain() -> VideoInfo {
        VideoInfo(
            id: id,
            title: title,
            thumbnailURL: thumbnail.flatMap(URL.init(string:)),
            duration: duration,
            uploader: uploader,
            formats: formats.filter { $0.hasVideo || $0.hasAudio }.map { $0.toDomain() }
        )
    }
}

struct YTDLPFormatDTO: Decodable {
    let formatId: String
    let ext: String
    let resolution: String?
    let fps: Double?
    let vcodec: String?
    let acodec: String?
    let filesize: Int64?
    let formatNote: String?
    let tbr: Double?

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

    func toDomain() -> VideoFormat {
        VideoFormat(
            formatId: formatId,
            ext: ext,
            resolution: resolution,
            fps: fps,
            vcodec: vcodec,
            acodec: acodec,
            filesize: filesize,
            formatNote: formatNote,
            tbr: tbr
        )
    }
}
