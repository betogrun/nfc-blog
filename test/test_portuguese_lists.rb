require "minitest_helper"

# Until every post is translated, the Portuguese lists show every post: the translation
# where there is one, the English post otherwise, marked as English (#127).
class TestPortugueseLists < Bridgetown::Test
  GEMS = "/posts/publishing-ruby-gems-with-github-actions".freeze
  GEMS_PT = "/pt#{GEMS}".freeze
  # The next post, with no translation yet.
  PAGY = "/posts/overwriting-pagy-navigation-helper".freeze

  def items = document.query_selector_all(".article-list-item")

  def item(href) = items.find { it.query_selector("a")[:href] == href }

  describe "home" do
    it "lists as many posts as the English home, translated where possible" do
      html get "/"
      count = items.size

      html get "/pt/"

      assert_equal count, items.size
      refute_nil item(GEMS_PT)
      refute_nil item(PAGY)
      assert_nil item(GEMS)
    end

    it "marks an untranslated post as English" do
      html get "/pt/"

      english = item(PAGY)
      label = english.query_selector(".article-list-language")

      assert_equal "en", english[:lang]
      assert_equal ["em inglês", "pt-BR"], [label.text.strip, label[:lang]]
      assert_nil item(GEMS_PT)[:lang]
      assert_nil item(GEMS_PT).query_selector(".article-list-language")
    end

    it "paginates like the English home" do
      html get "/posts/page/2/"
      count = items.size

      html get "/pt/posts/page/2/"

      assert_equal count, items.size
    end
  end

  describe "tag pages" do
    it "list untranslated posts too" do
      html get "/pt/tag/rails/"

      refute_nil item(PAGY)
    end

    it "exist in Portuguese only for tags with posts" do
      assert_predicate get("/tag/design/"), :ok?
      refute_predicate get("/pt/tag/design/"), :ok?
    end
  end

  describe "post page" do
    it "points the older-post link at the next post in the Portuguese list" do
      html get GEMS_PT

      assert_equal PAGY, document.query_selector(".article-nav-older")[:href]
    end
  end
end
