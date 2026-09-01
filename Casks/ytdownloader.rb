cask "ytdownloader" do
  version "1.0.0"
  sha256 "4d9ffe2613fdef116c54ee43b9dceaf09af2abaf8302c4db199525c17d97e033"

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
