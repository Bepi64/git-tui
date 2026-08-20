class GitTui < Formula
  desc "TUI pour parcourir un dépôt GitHub distant sans le cloner"
  homepage "https://github.com/Bepi64/git-tui"
  url "https://github.com/Bepi64/git-tui.git",
      tag:      "v0.2.0",
      revision: "fa7dfd64c9e41f0921f080ca6691d629bbdf64bd"
  license "Apache-2.0"

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "1"
    system "go", "build", "-trimpath", "-ldflags", "-s -w",
           "-o", bin/"git-tui", "./cmd/tui"
  end

  test do
    output = shell_output("#{bin}/git-tui 2>&1", 1)
    assert_match "usage:", output
  end
end
