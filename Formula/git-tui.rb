class GitTui < Formula
  desc "TUI pour parcourir un dépôt GitHub distant sans le cloner"
  homepage "https://github.com/Bepi64/git-tui"
  url "https://github.com/Bepi64/git-tui.git",
      tag:      "v0.3.0",
      revision: "PLACEHOLDER"
  license "Apache-2.0"

  depends_on "go" => :build

  resource "libgit2-plugin" do
    url "https://github.com/Bepi64/git-tui/releases/download/v0.2.0/plugin-darwin-arm64.bundle"
    sha256 "9761d53eb41ab41c23e10c087bfd239f10e4c8add1fdd9895ac514fbd685a40b"
  end

  def install
    resource("libgit2-plugin").stage do
      (lib/"git-tui").install "plugin-darwin-arm64.bundle" => "libgit2.dylib"
    end

    ENV["CGO_ENABLED"] = "1"
    ENV["CGO_LDFLAGS"] = "-Wl,-weak_library,#{lib}/git-tui/libgit2.dylib -Wl,-rpath,#{lib}/git-tui"
    system "go", "build", "-trimpath", "-ldflags", "-s -w",
           "-o", bin/"git-tui", "./cmd/tui"
  end

  test do
    output = shell_output("#{bin}/git-tui 2>&1", 1)
    assert_match "usage:", output
  end
end
