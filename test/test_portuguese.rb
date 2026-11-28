require "minitest_helper"

# The Portuguese version lives under /pt/ with the same slugs (#127).
class TestPortuguese < Bridgetown::Test
  GEMS = "/posts/publishing-ruby-gems-with-github-actions".freeze
  GEMS_PT = "/pt#{GEMS}".freeze

  describe "language of the page" do
    it "is English at the root and Brazilian Portuguese under /pt/" do
      html get "/"

      assert_equal "en", document.query_selector("html")[:lang]

      html get "/pt/"

      assert_equal "pt-BR", document.query_selector("html")[:lang]
    end
  end

  describe "posts" do
    it "serves a translation under /pt/ with the same slug" do
      html get GEMS_PT

      assert_equal "pt-BR", document.query_selector("html")[:lang]
      assert_equal "Publicando gems Ruby com GitHub Actions", document.query_selector(".article-header h1").text.strip
    end

    it "keeps each home to the posts in its language" do
      html get "/"

      titles = document.query_selector_all(".article-list-item h2").map { it.text.strip }

      assert_includes titles, "Publishing Ruby Gems with GitHub Actions"
      refute_includes titles, "Publicando gems Ruby com GitHub Actions"

      html get "/pt/"

      hrefs = document.query_selector_all(".article-list-item > a").map { it[:href] }

      assert_includes hrefs, GEMS_PT
      assert_empty(hrefs.reject { it.start_with?("/pt/") })
    end

    it "points the older-post link at a post in the same language" do
      html get GEMS

      refute document.query_selector(".article-nav-older")[:href].start_with?("/pt/")
    end
  end

  describe "interface" do
    it "translates the header and keeps the links in Portuguese" do
      html get GEMS_PT

      links = document.query_selector_all(".site-nav a").to_h { [it.text.strip, it[:href]] }

      assert_equal({ "Tags" => "/pt/tags", "Sobre" => "/pt/about" }, links)
      assert_equal "/pt/", document.query_selector(".site-masthead .site-name")[:href]
    end

    it "keeps the blog name in English" do
      html get "/pt/"

      assert_equal "Reflections & Refactors", document.query_selector(".site-name").text.split.join(" ")
    end

    it "shows the Portuguese subtitle on the Portuguese home" do
      html get "/pt/"

      assert_equal "Um diário de aventuras sobre software, ofício e IA.",
                   document.query_selector(".site-tagline").text
    end

    it "translates the footer labels" do
      html get "/pt/"

      labels = document.query_selector_all(".site-footer nav a").map { it["aria-label"] }

      assert_equal ["GitHub", "LinkedIn", "X", "E-mail", "Feed RSS"], labels
    end
  end

  describe "post page" do
    it "translates its labels and tag links" do
      html get GEMS_PT

      filed = document.query_selector(".article-filed")

      assert_includes filed.text, "arquivado em"
      assert_includes filed.query_selector_all("a").map { it[:href] }, "/pt/tag/ruby/"
      assert_equal "Sumário", document.query_selector(".article-nav-contents").text.strip
      assert_equal "/pt/", document.query_selector(".article-nav-contents")[:href]
    end

    it "has its own comment thread, with Disqus in Portuguese" do
      html get GEMS_PT

      thread = document.query_selector("#disqus_thread")

      assert_equal [GEMS_PT, "pt_BR"], [thread["data-disqus-identifier"], thread["data-disqus-language"]]
    end
  end

  describe "site pages" do
    it "has the tags page in Portuguese, counting only Portuguese posts" do
      html get "/pt/tags"

      assert_equal "pt-BR", document.query_selector("html")[:lang]
      assert_equal "/pt/tag/ruby/", document.query_selector("a.tag-cloud[href$='/ruby/']")[:href]
    end

    it "has a page per tag in Portuguese, with the translated name" do
      html get "/pt/tag/automation/"

      assert_equal "Automação", document.query_selector(".tag-header h1").text.strip
      assert_includes document.query_selector_all(".article-list-item > a").map { it[:href] }, GEMS_PT
    end

    it "says a tag has no posts yet in Portuguese" do
      html get "/pt/tag/design/"

      assert_includes document.query_selector(".article-empty").text, "Ainda não há posts em Design."
    end

    it "has the About page in Portuguese" do
      html get "/pt/about"

      assert_equal "pt-BR", document.query_selector("html")[:lang]
      assert_equal "Sobre mim", document.query_selector(".about h1").text.strip
    end

    it "has a Portuguese 404 page under /pt/" do
      html get "/pt/404.html"

      assert_includes document.query_selector(".notfound-content").text, "Parece que você se perdeu"
    end
  end
end
