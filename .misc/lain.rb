class Lain < Formula
  desc "CLI to communicate with LM Studio. Define sub-commands to query different LLMs with different parameters. Comes with sub-commands for generating documentation and simple `ask`."
  homepage "https://github.com/tfgrass/lain"
  url "https://github.com/yourusername/lain/archive/refs/tags/v0.1.tar.gz"
  sha256 "SHA-256 checksum of your release"
  license " Artistic-2.0" # or the appropriate license for your project

  depends_on "rakudo-star"
  depends_on "perl6-zef"

  def install
    ENV.prepend_path "PERL6LIB", libexec/"lib/perl6"
    zef = Formula["perl6-zef"].bin/"zef"
    system "#{Formula["rakudo-star"].bin}/raku", "-Ilib", "#{zef}", "install", "--deps-only", "--/test", "./"

    bin.install "bin/lain"
  end

  test do
    # This will run a basic smoke test to see if your script runs without errors
    system "#{bin}/lain", "version"
  end
end
