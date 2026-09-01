<p align="center">
  <img src="docs/icon.png" width="120" alt="YTDownloader アイコン" />
</p>

<h1 align="center">YTDownloader</h1>

<p align="center">
  <a href="https://github.com/yt-dlp/yt-dlp">yt-dlp</a> のためのネイティブ macOS GUI。<br />
  URL を貼り付けて、画質を選んで、ダウンロード — 一時停止・再開とリアルタイム進捗表示付き。
</p>

<p align="center">
  <a href="README.md">English</a> ·
  <a href="README.ko.md">한국어</a>
</p>

---

## 機能

- URL を貼り付けると `yt-dlp -J` でタイトル・サムネイル・利用可能なフォーマットを取得
- ダウンロード前に解像度・コンテナ形式を選択
- 速度と残り時間(ETA)を表示するリアルタイム進捗
- 一時停止・再開(yt-dlp の `--continue` により同じ位置から再開)
- 待機中・ダウンロード中の項目を削除
- 保存先と同時ダウンロード数を設定可能
- 英語・韓国語・日本語に対応

## 動作要件

- macOS 14.0 以降
- `PATH` 上に [yt-dlp](https://github.com/yt-dlp/yt-dlp) と `ffmpeg` が必要
  (`/opt/homebrew/bin`、`/usr/local/bin` を確認):
  ```sh
  brew install yt-dlp ffmpeg
  ```
- Xcode プロジェクト生成用の [Tuist](https://tuist.dev):
  ```sh
  curl -Ls https://install.tuist.io | bash
  ```

## ビルド・実行

```sh
tuist generate   # YTDownloader.xcworkspace を生成
open YTDownloader.xcworkspace
```

Xcode で `YTDownloader` スキームをビルド・実行するか、CLI から:

```sh
xcodebuild -workspace YTDownloader.xcworkspace -scheme YTDownloader -configuration Debug build
```

## アーキテクチャ

Tuist の4つのターゲットに分割されており、Clean Architecture の依存ルール
(内側のレイヤーは外側のレイヤーを決して import しない)に従っている:

```
Domain          エンティティ、リポジトリのプロトコル、ユースケース(依存なし)
  ↑
Data            yt-dlp/ffmpeg プロセス連携、Domain のリポジトリ実装
  ↑
Presentation    SwiftUI ビュー + ObservableObject ビューモデル(Domain のみに依存)
  ↑
App             組み立て役: Data のリポジトリを Presentation のビューモデルに
                注入してアプリを起動(3レイヤーすべてに依存)
```

- **Domain** — `VideoInfo`、`VideoFormat`、`DownloadStatus`、`VideoInfoRepository`/
  `DownloadRepository` プロトコル、薄いユースケース(`FetchVideoInfoUseCase`、
  `StartDownloadUseCase`、`PauseDownloadUseCase`、`CancelDownloadUseCase`)。
- **Data** — `YTDLPVideoInfoRepository`、`YTDLPDownloadRepository` が `Process` で
  `yt-dlp` を実行し、`-J` の JSON 出力と `--progress-template` の出力を解析する。
  `BinaryManager` が `yt-dlp`/`ffmpeg` の実行ファイルを探す。
- **Presentation** — `DownloadListViewModel` が `pendingItems`/`activeItems` という
  2つの `@Published` 配列を保持し、ダウンロード開始時に項目が配列間を移動する。
  `ContentView` などがそれを描画する。
- **App** — `YTDownloaderApp` が実際のリポジトリを組み立て、ビューモデルに注入する。

## プロジェクト構成

```
Domain/Sources/{Entities,Repositories,UseCases}
Data/Sources/{DTOs,Repositories}
Presentation/Sources/{Views,ViewModels}
App/Sources, App/Resources
Project.swift, Tuist.swift
```

## 補足

- 外部の `yt-dlp` プロセスを実行する構造のため、サンドボックス権限は無効化している —
  App Store 配布には別のアプローチが必要。
- ダウンロードの既定保存先は `~/Downloads`。設定画面から変更可能。
