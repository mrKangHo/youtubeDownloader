<p align="center">
  <img src="docs/icon.png" width="120" alt="YTDownloader icon" />
</p>

<h1 align="center">YTDownloader</h1>

<p align="center">
  A native macOS GUI for <a href="https://github.com/yt-dlp/yt-dlp">yt-dlp</a>.<br />
  Paste a YouTube URL, pick a quality, download — with pause/resume and live progress.
</p>

<p align="center">
  <a href="README.ko.md">한국어</a> ·
  <a href="README.ja.md">日本語</a>
</p>

---

## Features

- Paste a URL, fetch title/thumbnail/available formats via `yt-dlp -J`
- Pick resolution and container format before downloading
- Live progress with speed and ETA
- Pause / resume (resumes from the same byte offset via yt-dlp's `--continue`)
- Delete a queued or in-flight download
- Configurable save location and max concurrent downloads
- App localized in English, Korean, and Japanese

## Install

```sh
brew tap mrKangHo/ytdownloader https://github.com/mrKangHo/youtubeDownloader
brew install --cask ytdownloader
```

This also installs `yt-dlp` and `ffmpeg` as dependencies. The cask formula lives
in [`Casks/ytdownloader.rb`](Casks/ytdownloader.rb).

## Requirements

- macOS 14.0+
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) and `ffmpeg` on `PATH` (checked in `/opt/homebrew/bin` and `/usr/local/bin`):
  ```sh
  brew install yt-dlp ffmpeg
  ```
- [Tuist](https://tuist.dev) to generate the Xcode project:
  ```sh
  curl -Ls https://install.tuist.io | bash
  ```

## Build & run

```sh
tuist generate   # generates YTDownloader.xcworkspace
open YTDownloader.xcworkspace
```

Build and run the `YTDownloader` scheme from Xcode, or from the CLI:

```sh
xcodebuild -workspace YTDownloader.xcworkspace -scheme YTDownloader -configuration Debug build
```

## Architecture

The project is split into four Tuist targets that follow Clean Architecture's
dependency rule — inner layers never import outer ones:

```
Domain          entities, repository protocols, use cases (no dependencies)
  ↑
Data            yt-dlp/ffmpeg process integration, implements Domain's repositories
  ↑
Presentation    SwiftUI views + ObservableObject view models (depends on Domain only)
  ↑
App             composition root: wires Data's repositories into Presentation's
                view model and launches the app (depends on all three)
```

- **Domain** — `VideoInfo`, `VideoFormat`, `DownloadStatus`, the `VideoInfoRepository` /
  `DownloadRepository` protocols, and thin use cases (`FetchVideoInfoUseCase`,
  `StartDownloadUseCase`, `PauseDownloadUseCase`, `CancelDownloadUseCase`).
- **Data** — `YTDLPVideoInfoRepository` and `YTDLPDownloadRepository` spawn `yt-dlp`
  via `Process`, parsing its `-J` JSON output and `--progress-template` stream.
  `BinaryManager` locates the `yt-dlp`/`ffmpeg` executables.
- **Presentation** — `DownloadListViewModel` holds two `@Published` arrays
  (`pendingItems`, `activeItems`) that items move between as they start
  downloading; `ContentView` and friends render them.
- **App** — `YTDownloaderApp` builds the concrete repositories and injects them
  into the view model.

## Project layout

```
Domain/Sources/{Entities,Repositories,UseCases}
Data/Sources/{DTOs,Repositories}
Presentation/Sources/{Views,ViewModels}
App/Sources, App/Resources
Project.swift, Tuist.swift
```

## Notes

- No sandbox entitlement is set, since the app spawns an external `yt-dlp`
  process — App Store distribution would need a different approach.
- Downloads default to `~/Downloads`; changeable in Settings.
