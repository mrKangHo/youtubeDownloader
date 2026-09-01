cask "ytdownloader" do
  version "1.1.0"
  sha256 "ec87b4dc064424527e9c2619dd92c7ee3cef72c42c2b9ebc1910c431c0cfea4f"

  url "https://github.com/mrKangHo/youtubeDownloader/releases/download/v#{version}/YTDownloader-#{version}.dmg"
  name "YTDownloader"
  desc "GUI for yt-dlp"
  homepage "https://github.com/mrKangHo/youtubeDownloader"

  depends_on macos: :sonoma
  depends_on formula: "yt-dlp"
  depends_on formula: "ffmpeg"

  app "YTDownloader.app"

  zap trash: "~/Library/Preferences/com.coke8707.YTDownloader.plist"

  caveats <<~EOS
    YTDownloader is signed ad-hoc (no paid Apple Developer ID), so the first
    launch will be blocked by Gatekeeper as "from an unidentified developer".
    Right-click the app in Applications and choose Open, or run:
      xattr -cr /Applications/YTDownloader.app
  EOS
end
