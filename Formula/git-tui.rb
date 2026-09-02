class GitTui < Formula
  desc "TUI pour parcourir un dépôt GitHub distant sans le cloner"
  homepage "https://github.com/bepi64/homebrew-tap"
  url "https://github.com/bepi64/homebrew-tap.git",
      tag: "v3.0.0"
  license "Apache-2.0"

  depends_on "go" => :build

  resource "libgit2-plugin" do
    url "https://github.com/bepi64/homebrew-tap/releases/download/v0.2.0/plugin-darwin-arm64.bundle"
    sha256 "7fe1a8d9399b16aa74260f0e54977e7d0f6a01cd773d3c3207e57a28cbc70dcc"
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
