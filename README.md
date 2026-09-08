🇰🇷 [한국어](README.md) | 🇺🇸 [English](README.en.md) | 🇯🇵 [日本語](README.ja.md) | 🇨🇳 [中文](README.zh.md)

<p align="center">
  <img src="docs/icon.png" width="128" alt="YTDownloader icon" />
</p>

<h1 align="center">YTDownloader</h1>

<p align="center">
  <a href="https://github.com/yt-dlp/yt-dlp">yt-dlp</a>를 기반으로 동작하는 macOS 네이티브 동영상 다운로더 GUI 앱입니다.<br />
  유튜브 URL을 붙여넣고 해상도를 선택하여 간편하게 다운로드할 수 있으며, 일시정지/이어받기 및 실시간 진행 상태를 제공합니다.
</p>

<p align="center">
  <img src="docs/screenshot.png" alt="YTDownloader screenshot" width="800" />
</p>

## 주요 기능

- 유튜브 URL 입력 시 `yt-dlp -J`를 통해 제목, 썸네일, 가능한 화질 목록 자동 파싱
- 다운로드 전 해상도 및 비디오/오디오 포맷(MP4, WebM, MP3 등) 선택
- 실시간 다운로드 속도 및 예상 소요 시간(ETA) 표시
- 일시정지 및 이어받기 지원 (`yt-dlp --continue` 활용)
- 다운로드 대기열 관리 및 삭제 기능
- 앱 내 유튜브 브라우징 지원 (시청 중인 영상을 바로 대기열에 추가)

## 설치 (Installation)

### Homebrew
```bash
brew tap mrKangHo/tap
brew install youtubedownloader
```

또는 전용 탭 사용:
```bash
brew tap mrKangHo/homebrew-ytdownloader
brew install ytdownloader
```

### 직접 다운로드

[Releases](../../releases) 페이지에서 `YTDownloader-*.dmg`를 다운로드하여 설치할 수 있습니다.
