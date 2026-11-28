require "minitest_helper"
# Tests serve the built site and never boot its autoloader, so load the component directly.
require_relative "../src/_components/share_links"

# The links in the row the share button opens on desktops (#145).
class TestShareLinks < Minitest::Test
  URL = "https://blog.albertorocha.me/posts/some-post".freeze
  TITLE = "Tests & gems: a 100% guide?".freeze
  ENCODED_URL = "https%3A%2F%2Fblog.albertorocha.me%2Fposts%2Fsome-post".freeze
  ENCODED_TITLE = "Tests%20%26%20gems%3A%20a%20100%25%20guide%3F".freeze

  def links(**) = ShareLinks.links(title: TITLE, url: URL, **).to_h { [it.name, it.href] }

  def test_lists_the_networks_in_order_then_email
    assert_equal ["LinkedIn", "Bluesky", "X", "Hacker News", "Reddit", "email"], links.keys
  end

  def test_builds_each_share_link_from_the_encoded_title_and_url
    expected = {
      "LinkedIn" => "https://www.linkedin.com/sharing/share-offsite/?url=#{ENCODED_URL}",
      "Bluesky" => "https://bsky.app/intent/compose?text=#{ENCODED_TITLE}%20#{ENCODED_URL}",
      "X" => "https://x.com/intent/post?text=#{ENCODED_TITLE}&url=#{ENCODED_URL}",
      "Hacker News" => "https://news.ycombinator.com/submitlink?u=#{ENCODED_URL}&t=#{ENCODED_TITLE}",
      "Reddit" => "https://www.reddit.com/submit?url=#{ENCODED_URL}&title=#{ENCODED_TITLE}",
      "email" => "mailto:?subject=#{ENCODED_TITLE}&body=#{ENCODED_URL}"
    }

    assert_equal expected, links
  end

  def test_encodes_accented_titles_as_utf8
    x = ShareLinks.links(title: "Publicação", url: URL).find { it.name == "X" }

    assert_equal "https://x.com/intent/post?text=Publica%C3%A7%C3%A3o&url=#{ENCODED_URL}", x.href
  end

  def test_names_the_email_link_in_the_given_language
    assert_equal "e-mail", links(email: "e-mail").keys.last
  end

  def test_opens_only_the_networks_in_a_new_tab
    external = ShareLinks.links(title: TITLE, url: URL).to_h { [it.name, it.external?] }

    assert_equal(([true] * 5) + [false], external.values)
  end
end

# The row on post pages, under "filed under". Phones keep the system share sheet instead,
# a choice share.js makes in the browser.
class TestSharePage < Bridgetown::Test
  PAGY = "/posts/overwriting-pagy-navigation-helper".freeze

  def squish(text) = text.split.join(" ")

  it "makes the share button disclose a hidden row of share links" do
    html get PAGY

    share = document.query_selector("button[data-share]")
    row = document.query_selector(".article-filed + .share-links[hidden]")

    assert_equal %w[false share-links], [share["aria-expanded"], share["aria-controls"]]
    assert_equal "share-links", row[:id]
  end

  {
    PAGY => ["Overwriting the Pagy Navigation Helper", "copy link", "email"],
    "/pt/posts/publishing-ruby-gems-with-github-actions" =>
      ["Publicando gems Ruby com GitHub Actions", "copiar link", "e-mail"]
  }.each do |path, (title, copy, email)|
    it "shares the title and URL of #{path} in its language" do
      html get path

      row = document.query_selector(".share-links")
      url = ERB::Util.url_encode("https://blog.albertorocha.me#{path}")
      links = row.query_selector_all("a").to_h { [squish(it.text), it[:href]] }

      assert_equal [copy, "https://blog.albertorocha.me#{path}"],
                   [squish(row.query_selector("button").text), row.query_selector("button")["data-share-url"]]
      assert_equal ["LinkedIn", "Bluesky", "X", "Hacker News", "Reddit", email], links.keys
      assert_equal "https://x.com/intent/post?text=#{ERB::Util.url_encode(title)}&url=#{url}", links["X"]
      assert_equal "mailto:?subject=#{ERB::Util.url_encode(title)}&body=#{url}", links[email]
    end
  end

  it "opens the networks in a new tab, and email in the reader's mail app" do
    html get PAGY

    external = document.query_selector_all(".share-links a[href^='https://']")
    email = document.query_selector(".share-links a[href^='mailto:']")

    assert_equal 5, external.size
    assert(external.all? { it[:target] == "_blank" && it[:rel] == "noopener" })
    assert_nil email[:target]
  end

  it "hands the copy link button its messages in the page's language" do
    html get "/pt/posts/publishing-ruby-gems-with-github-actions"

    copy = document.query_selector(".share-links button")

    assert_equal ["link copiado", "não foi possível copiar", "polite"],
                 [copy["data-share-copied"], copy["data-share-failed"], copy["aria-live"]]
  end
end
