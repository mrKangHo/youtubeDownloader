🇰🇷 [한국어](README.md) | 🇺🇸 [English](README.en.md) | 🇯🇵 [日本語](README.ja.md) | 🇨🇳 [中文](README.zh.md)

<p align="center">
  <img src="docs/icon.png" width="128" alt="YTDownloader icon" />
</p>

<h1 align="center">YTDownloader</h1>

<p align="center">
  A native macOS GUI for <a href="https://github.com/yt-dlp/yt-dlp">yt-dlp</a>.<br />
  Paste a YouTube URL, pick a quality, download — with pause/resume and live progress.
</p>

<p align="center">
  <img src="docs/screenshot.png" alt="YTDownloader screenshot" width="800" />
</p>

## Features

- Paste a URL, fetch title/thumbnail/available formats via `yt-dlp -J`
- Pick resolution and container format before downloading
- Live progress with speed and ETA
- Pause / resume (resumes from the same byte offset via yt-dlp's `--continue`)
- Delete a queued or in-flight download
- In-app YouTube browser: browse youtube.com inside the app and download directly

## Installation

### Homebrew
```bash
brew tap mrKangHo/tap
brew install youtubedownloader
```

Or via direct tap:
```bash
brew tap mrKangHo/homebrew-ytdownloader
brew install ytdownloader
```
