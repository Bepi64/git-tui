class GitTui < Formula
  desc "TUI pour parcourir un dépôt GitHub distant sans le cloner"
  homepage "https://github.com/Bepi64/git-tui"
  url "https://github.com/Bepi64/git-tui.git",
      tag:      "v2.2.0",
      revision: "7ad927835504840635f563ae70c40ab33adc929e"
  license "Apache-2.0"

  depends_on "go" => :build

  resource "libgit2-plugin" do
    url "https://github.com/Bepi64/git-tui/releases/download/v0.2.0/plugin-darwin-arm64.bundle"
    sha256 "bb6271ae640d6627c624b2a2c83447955c01c1e42ad391025d365b4081c1fff7"
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
