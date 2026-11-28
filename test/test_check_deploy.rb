require "minitest_helper"
require "puma"
require_relative "../config/custom_commands"

# A fake deploy for check_deploy: its pages, sitemap, feeds and 404s.
module CheckDeployFixtures
  SITE = "https://blog.example.test".freeze
  NOT_FOUND = %(<html lang="en"><div class="notfound-wrapper">lost</div></html>).freeze
  NOT_FOUND_PT = %(<html lang="pt-BR"><div class="notfound-wrapper">perdido</div></html>).freeze
  # Each language's 404 page for a path under it.
  MISSING = %w[/check-deploy-missing-page /pt/check-deploy-missing-page].freeze
  HEALTHY_MISSING = ->(path) { [404, path.start_with?("/pt/") ? NOT_FOUND_PT : NOT_FOUND] }

  # Serves the given pages; anything else gets `missing`, a response or a lambda of the path.
  class FakeHost
    def initialize(pages, missing:)
      @pages = pages
      @missing = missing
    end

    def get(path)
      status, body, location = @pages.fetch(path) { @missing.respond_to?(:call) ? @missing.call(path) : @missing }
      Commands::CheckDeploy::Response.new(status:, body:, location:)
    end
  end

  def sitemap(*paths) = "<urlset>#{paths.map { "<url><loc>#{SITE}#{it}</loc></url>" }.join}</urlset>"

  # A sitemap URL with its translation, the way bridgetown-sitemap lists it.
  def sitemap_with_translation(path, translation)
    %(<urlset><url><loc>#{SITE}#{path}</loc>) +
      %(<xhtml:link rel="alternate" hreflang="pt" href="#{SITE}#{translation}" /></url></urlset>)
  end

  def feed(*paths, at: "/feed.xml")
    %(<feed><link href="#{SITE}#{at}" rel="self"/>#{paths.map { entry(it) }.join}</feed>)
  end

  def entry(path) = %(<entry><link href="#{SITE}#{path}" rel="alternate"/></entry>)

  # A deploy where everything resolves: the legacy paths, sitemap, feed and robots.txt.
  def healthy_pages
    {
      "/" => [200, "home"], "/about" => [200, "about"], "/posts/hello" => [200, "post"],
      "/pt/posts/hello" => [200, "post"],
      "/sitemap.xml" => [200, sitemap("/", "/about", "/posts/hello")],
      "/feed.xml" => [200, feed("/posts/hello")],
      "/pt/feed.xml" => [200, feed("/pt/posts/hello", at: "/pt/feed.xml")],
      "/robots.txt" => [200, "Sitemap: #{SITE}/sitemap.xml"]
    }
  end

  def problems(pages, legacy: ["/", "/about"], missing: HEALTHY_MISSING)
    Commands::CheckDeploy.problems(FakeHost.new(pages, missing:), site_url: SITE, legacy_paths: legacy)
  end
end

class TestCheckDeploy < Minitest::Test
  include CheckDeployFixtures

  def test_is_registered_as_check_deploy_with_a_required_url
    command = Bridgetown::Commands::Application.parse(["check_deploy", "https://preview.example.test"]).command

    assert_instance_of Commands::CheckDeploy, command
    assert_equal "https://preview.example.test", command.url
  end

  def test_passes_when_every_page_resolves
    assert_empty problems(healthy_pages)
  end

  def test_reports_a_missing_legacy_url
    assert_equal ["/posts/gone: status 404, expected 200"], problems(healthy_pages, legacy: ["/posts/gone"])
  end

  # A redirect changes the URL search engines and other sites link to.
  def test_reports_a_redirect_with_its_target
    pages = healthy_pages.merge("/about" => [307, "", "/about/"])

    assert_equal ["/about: status 307 to /about/, expected 200"], problems(pages)
  end

  def test_checks_every_sitemap_and_feed_url
    pages = healthy_pages.merge(
      "/sitemap.xml" => [200, sitemap("/", "/tag/ruby/")],
      "/feed.xml" => [200, feed("/posts/missing")]
    )

    assert_equal ["/tag/ruby/: status 404, expected 200", "/posts/missing: status 404, expected 200"],
                 problems(pages)
  end

  def test_checks_the_portuguese_feed_and_the_translations_in_the_sitemap
    pages = healthy_pages.merge(
      "/sitemap.xml" => [200, sitemap_with_translation("/about", "/pt/about")],
      "/pt/feed.xml" => [200, feed("/pt/posts/missing", at: "/pt/feed.xml")]
    )

    assert_equal ["/pt/about: status 404, expected 200", "/pt/posts/missing: status 404, expected 200"],
                 problems(pages)
  end

  def test_ignores_urls_of_other_sites
    pages = healthy_pages.merge("/sitemap.xml" => [200, "<urlset><loc>#{SITE}ing/x</loc><loc>https://other.test/y</loc></urlset>"])

    assert_empty problems(pages)
  end

  def test_reports_missing_sitemap_feed_and_robots
    pages = healthy_pages.except("/sitemap.xml", "/feed.xml", "/pt/feed.xml", "/robots.txt")

    assert_equal %w[/sitemap.xml /feed.xml /pt/feed.xml /robots.txt].map { "#{it}: status 404, expected 200" },
                 problems(pages)
  end

  # Unknown paths must get the site's 404 page with a 404 status, not a 200 or a bare error.
  def test_reports_a_missing_not_found_page
    expected = MISSING.map { "#{it}: status 404 without the site's 404 page" }

    assert_equal expected, problems(healthy_pages, missing: [404, "Not Found"])
  end

  def test_reports_a_soft_not_found
    assert_equal MISSING.map { "#{it}: status 200, expected 404" }, problems(healthy_pages, missing: [200, "home"])
  end

  # Cloudflare serves the nearest 404.html, so a missing path under /pt/ gets the Portuguese one.
  def test_reports_the_english_not_found_page_under_pt
    assert_equal ["/pt/check-deploy-missing-page: status 404 without the site's 404 page"],
                 problems(healthy_pages, missing: [404, NOT_FOUND])
  end

  # Cloudflare features such as Email Address Obfuscation rewrite pages and load scripts from
  # /cdn-cgi/; the build never references it, so the deployed pages must not either.
  def test_reports_pages_rewritten_by_cloudflare
    rewritten = %(<a href="/cdn-cgi/l/email-protection" class="__cf_email__">[email&#160;protected]</a>)
    pages = healthy_pages.merge("/posts/hello" => [200, rewritten])

    assert_equal ["/posts/hello: rewritten by Cloudflare (references /cdn-cgi/)"], problems(pages)
  end

  def test_call_exits_with_failure_and_lists_the_problems
    serve(->(_env) { [404, {}, ["nope"]] }) do |url|
      command = Commands::CheckDeploy[url]

      out, = capture_io do
        error = assert_raises(SystemExit) { command.call }

        refute_predicate error, :success?
      end

      assert_match "/about: status 404, expected 200", out
      assert_match "problem(s) on #{url}", out
    end
  end

  # The real client talks HTTP, keeps redirects as they are, and sends the request path as given.
  def test_http_client_returns_status_body_and_location
    redirects = { "/tag/ruby" => "/tag/ruby/" }
    app = lambda do |env|
      path = env["PATH_INFO"]
      redirects.key?(path) ? [307, { "location" => redirects[path] }, []] : [200, {}, ["page #{path}"]]
    end

    serve(app) do |url|
      client = Commands::CheckDeploy::Client.new(url)

      assert_equal [200, "page /posts/hello", nil], client.get("/posts/hello").deconstruct
      assert_equal [307, "", "/tag/ruby/"], client.get("/tag/ruby").deconstruct
    end
  end

  def test_http_client_keeps_a_path_prefix_in_the_base_url
    serve(->(env) { [200, {}, [env["PATH_INFO"]]] }) do |url|
      assert_equal "/base/about", Commands::CheckDeploy::Client.new("#{url}/base/").get("/about").body
    end
  end

  private

  def serve(app)
    server = Puma::Server.new(app, nil, min_threads: 0, max_threads: 1, log_writer: Puma::LogWriter.null)
    port = server.add_tcp_listener("127.0.0.1", 0).addr[1]
    server.run
    yield "http://127.0.0.1:#{port}"
  ensure
    server&.stop(true)
  end
end
