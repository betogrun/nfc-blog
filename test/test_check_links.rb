require "minitest_helper"
require "tmpdir"
require_relative "../config/custom_commands"

class TestCheckLinks < Minitest::Test
  SITE = "https://blog.example.test".freeze
  KNOWN = { "posts/old.html" => ["'a' tag is missing a reference"] }.freeze

  def setup
    @root = Dir.mktmpdir
    write "favicon.ico", ""
  end

  def teardown
    FileUtils.rm_rf @root
  end

  def write(path, content)
    file = File.join(@root, path)
    FileUtils.mkdir_p File.dirname(file)
    File.write(file, content)
  end

  # Every page of the real site has a favicon, which the Favicon check requires.
  def page(path, body, head: "")
    write path, <<~HTML
      <!DOCTYPE html>
      <html>
      <head><title>t</title><link rel="icon" href="/favicon.ico">#{head}</head>
      <body>#{body}</body>
      </html>
    HTML
  end

  def problems(external: false, known: {})
    Commands::CheckLinks.failures(@root, site_url: SITE, external:, known:)
  end

  def descriptions = problems.map(&:description)

  def test_is_registered_as_check_links_with_external_links_opt_in
    default = Bridgetown::Commands::Application.parse(["check_links"]).command
    external = Bridgetown::Commands::Application.parse(["check_links", "--external", "public"]).command

    assert_instance_of Commands::CheckLinks, default
    assert_equal ["output", nil], [default.directory, default.options[:external]]
    assert_equal ["public", true], [external.directory, external.options[:external]]
  end

  # Static hosts serve /posts/slug from posts/slug.html and /tag/x/ from tag/x/index.html.
  def test_passes_when_links_resolve_the_way_the_host_serves_them
    page "index.html", %(<a href="/posts/hello">post</a> <a href="/tag/ruby/">tag</a> <img src="/images/a.png" alt="a">)
    page "posts/hello.html", %(<a href="/">home</a> <a href="#comments">comments</a><div id="comments"></div>)
    page "tag/ruby/index.html", "tag"
    write "images/a.png", ""

    assert_empty problems
  end

  def test_reports_a_broken_internal_link
    page "index.html", %(<a href="/posts/missing">post</a>)

    assert_equal 1, problems.size
    assert_match "posts/missing", problems.first.description
  end

  def test_reports_missing_images_and_anchors
    page "index.html", %(<img src="/images/missing.png" alt="a"> <a href="#nowhere">jump</a>)

    assert_equal 2, problems.size
    assert_match(%r{images/missing\.png.*#nowhere}m, descriptions.join("\n"))
  end

  # Canonical, og:url and the share link use the full site URL; they must point into the build.
  def test_checks_absolute_site_urls_against_the_build
    page "index.html", "home", head: %(<link rel="canonical" href="#{SITE}/">)
    page "about.html", "about", head: %(<link rel="canonical" href="#{SITE}/about">)

    assert_empty problems

    page "about.html", "about", head: %(<link rel="canonical" href="#{SITE}/abuot">)

    assert_match "abuot", descriptions.join
  end

  def test_checks_external_links_only_when_asked
    page "index.html", %(<a href="https://localhost:1/">down</a>)

    assert_empty problems
    refute_empty problems(external: true)
  end

  def test_relative_paths_of_failures_match_known_entries
    page "posts/old.html", %(<a href="">link</a>)

    assert_empty problems(known: KNOWN)
  end

  # A known entry that no longer fails was fixed: the list must shrink with it.
  def test_reports_known_failures_that_are_gone
    page "posts/old.html", %(<a href="/posts/old">link</a>)

    stale = problems(known: KNOWN)

    assert_equal ["posts/old.html"], stale.map(&:path)
    assert_match "no longer fails", stale.first.description
  end

  # Entries for pages missing from a build are skipped, so a renamed post must take its
  # entry along; otherwise the entry would silently stop doing anything. A translation
  # (slug.pt.md) is built under pt/.
  def test_known_failures_belong_to_existing_posts
    sources = Dir[File.expand_path("../src/_posts/*.md", __dir__)]
    paths = sources.map { File.basename(it, ".md").sub(/\A\d{4}-\d{2}-\d{2}-/, "").split(".") }
                   .map { |slug, locale| [locale, "posts/#{slug}.html"].compact.join("/") }

    Commands::CheckLinks::KNOWN_FAILURES.each_key do |path|
      assert_includes paths, path
    end
  end

  def test_skips_known_failures_of_pages_the_build_does_not_have
    page "index.html", "fine"

    assert_empty problems(known: KNOWN)
  end

  def test_call_exits_with_failure_and_lists_the_problems
    page "index.html", %(<a href="/posts/missing">post</a>)
    command = Commands::CheckLinks[@root]

    out, = capture_io do
      error = assert_raises(SystemExit) { command.call }

      refute_predicate error, :success?
    end

    assert_match "index.html", out
    assert_match "posts/missing", out
  end

  def test_call_succeeds_quietly_on_a_clean_build
    page "index.html", "fine"

    out, = capture_io { Commands::CheckLinks[@root].call }

    assert_match "no broken links", out
  end
end
