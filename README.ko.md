<p align="center">
  <img src="docs/icon.png" width="120" alt="YTDownloader 아이콘" />
</p>

<h1 align="center">YTDownloader</h1>

<p align="center">
  <a href="https://github.com/yt-dlp/yt-dlp">yt-dlp</a>를 위한 네이티브 macOS GUI.<br />
  URL 붙여넣고, 화질 고르고, 다운로드 — 일시정지/재개와 실시간 진행률까지.
</p>

<p align="center">
  <a href="README.md">English</a> ·
  <a href="README.ja.md">日本語</a>
</p>

---

## 기능

- URL 붙여넣으면 `yt-dlp -J`로 제목/썸네일/포맷 목록 조회
- 다운로드 전 해상도·컨테이너 포맷 선택
- 속도·남은 시간(ETA)까지 보여주는 실시간 진행률
- 일시정지/재개 (yt-dlp `--continue`로 받던 지점부터 이어받음)
- 대기 중이거나 진행 중인 항목 삭제
- 저장 위치, 동시 다운로드 개수 설정
- 영어/한국어/일본어 다국어 지원

## 요구 사항

- macOS 14.0+
- `PATH`에 [yt-dlp](https://github.com/yt-dlp/yt-dlp)와 `ffmpeg` 필요 (`/opt/homebrew/bin`, `/usr/local/bin` 확인):
  ```sh
  brew install yt-dlp ffmpeg
  ```
- Xcode 프로젝트 생성용 [Tuist](https://tuist.dev):
  ```sh
  curl -Ls https://install.tuist.io | bash
  ```

## 빌드 & 실행

```sh
tuist generate   # YTDownloader.xcworkspace 생성
open YTDownloader.xcworkspace
```

Xcode에서 `YTDownloader` 스킴으로 빌드/실행하거나, CLI로:

```sh
xcodebuild -workspace YTDownloader.xcworkspace -scheme YTDownloader -configuration Debug build
```

## 아키텍처

Tuist 타겟 4개로 나뉘어 있고, Clean Architecture의 의존성 규칙(안쪽 레이어는
바깥 레이어를 절대 import하지 않음)을 따른다:

```
Domain          엔티티, 리포지토리 프로토콜, 유스케이스 (의존성 없음)
  ↑
Data            yt-dlp/ffmpeg 프로세스 연동, Domain 리포지토리 구현체
  ↑
Presentation    SwiftUI 뷰 + ObservableObject 뷰모델 (Domain에만 의존)
  ↑
App             조립부: Data 리포지토리를 Presentation 뷰모델에 주입 후 앱 실행
                (세 레이어 모두에 의존)
```

- **Domain** — `VideoInfo`, `VideoFormat`, `DownloadStatus`, `VideoInfoRepository`/
  `DownloadRepository` 프로토콜, 얇은 유스케이스(`FetchVideoInfoUseCase`,
  `StartDownloadUseCase`, `PauseDownloadUseCase`, `CancelDownloadUseCase`).
- **Data** — `YTDLPVideoInfoRepository`, `YTDLPDownloadRepository`가 `Process`로
  `yt-dlp`를 실행해 `-J` JSON 응답과 `--progress-template` 출력을 파싱한다.
  `BinaryManager`가 `yt-dlp`/`ffmpeg` 실행 파일 위치를 찾는다.
- **Presentation** — `DownloadListViewModel`이 `pendingItems`/`activeItems` 두
  `@Published` 배열을 갖고, 다운로드 시작 시 항목이 배열 사이를 이동한다.
  `ContentView` 등이 이를 그린다.
- **App** — `YTDownloaderApp`이 실제 리포지토리를 만들어 뷰모델에 주입한다.

## 프로젝트 구조

```
Domain/Sources/{Entities,Repositories,UseCases}
Data/Sources/{DTOs,Repositories}
Presentation/Sources/{Views,ViewModels}
App/Sources, App/Resources
Project.swift, Tuist.swift
```

## 참고

- 외부 `yt-dlp` 프로세스를 실행하는 구조라 샌드박스 권한을 켜지 않음 —
  App Store 배포하려면 다른 접근이 필요함.
- 다운로드 기본 저장 위치는 `~/Downloads`, 설정에서 변경 가능.
