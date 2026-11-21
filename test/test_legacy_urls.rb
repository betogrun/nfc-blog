require "minitest_helper"

# Every URL the Jekyll site served must exist in the Bridgetown build, so links from
# search engines and other sites keep working after the migration.
class TestLegacyUrls < Minitest::Test
  OUTPUT = File.expand_path("../output", __dir__)
  FIXTURE = File.expand_path("fixtures/legacy_urls.txt", __dir__)

  def self.legacy_paths
    File.readlines(FIXTURE, chomp: true).reject { it.empty? || it.start_with?("#") }
  end

  # Static hosts (GitHub Pages, Cloudflare) serve "/foo/" from foo/index.html and
  # "/foo" from foo.html without redirecting. Anything else would change the URL.
  def output_file_for(path)
    File.join(OUTPUT, path.end_with?("/") ? "#{path}index.html" : "#{path}.html")
  end

  legacy_paths.each do |path|
    define_method("test_serves #{path}") do
      assert_path_exists output_file_for(path), "#{path} is missing from the build"
    end
  end
end
