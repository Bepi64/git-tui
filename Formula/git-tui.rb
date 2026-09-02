class GitTui < Formula
  desc "TUI pour parcourir un dépôt GitHub distant sans le cloner"
  homepage "https://github.com/bepi64/homebrew-tap"
  url "https://github.com/bepi64/homebrew-tap.git",
      tag:      "v2.0.0",
      revision: "50ec1c48c6bac6adc3b1dceb3dc3c833bc50e12e"
  license "Apache-2.0"

  depends_on "go" => :build

  resource "libgit2-plugin" do
    url "https://github.com/bepi64/homebrew-tap/releases/download/v0.2.0/plugin-darwin-arm64.bundle"
    sha256 "70b4c98748344761c93e97f29dc289faaa4998f8b065fcf05ad89ed5b1c4e19b"
  end

  def install
    resource("libgit2-plugin").stage do
      (lib/"git-tui").install "plugin-darwin-arm64.bundle" => "libgit2.dylib"
    end

    ENV["CGO_ENABLED"] = "1"
    ENV["CGO_LDFLAGS"] = "-Wl,-weak_library,#{lib}/git-tui/libgit2.dylib -Wl,-rpath,#{lib}/git-tui"
    system "go", "build", "-trimpath", "-ldflags", "-s -w",
           "-o", bin/"git-tui", "."
  end

  service do
    run [opt_bin/"git-tui"]
    keep_alive true
    log_path "/dev/null"
    error_log_path "/dev/null"
  end

  test do
    output = shell_output("#{bin}/git-tui 2>&1", 1)
    assert_match "usage:", output
  end
end
