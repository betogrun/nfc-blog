require "minitest_helper"

# The EN · PT selector next to the theme toggle, and the hreflang links behind it (#127).
class TestLanguageSelector < Bridgetown::Test
  SITE = "https://blog.albertorocha.me".freeze
  GEMS = "/posts/publishing-ruby-gems-with-github-actions".freeze
  GEMS_PT = "/pt#{GEMS}".freeze
  # A post with no translation yet.
  PAGY = "/posts/overwriting-pagy-navigation-helper".freeze

  def selector = document.query_selector(".site-bar .language-nav")

  def choices = selector.query_selector_all("a").to_h { [it.text.strip, it] }

  def alternates
    document.query_selector_all("link[rel='alternate'][hreflang]").to_h { [it[:hreflang], it[:href]] }
  end

  def meta(property) = document.query_selector_all("meta[property='#{property}']").map { it[:content] }

  describe "selector" do
    it "sits before the theme toggle, with the current language marked" do
      html get GEMS

      assert_equal "theme-toggle", selector.next_element[:class]
      assert_equal %w[EN PT], choices.keys
      assert_equal "true", choices["EN"]["aria-current"]
      assert_nil choices["PT"]["aria-current"]
    end

    it "links each language to the same page in it" do
      html get GEMS

      assert_equal([GEMS_PT, "pt-BR", "pt"], choices["PT"].then { [it[:href], it[:hreflang], it["data-locale"]] })

      html get GEMS_PT

      assert_equal([GEMS, "en", "en"], choices["EN"].then { [it[:href], it[:hreflang], it["data-locale"]] })
      assert_equal "true", choices["PT"]["aria-current"]
    end

    it "names the languages for screen readers, each in its own language" do
      html get GEMS

      assert_equal([%w[English en], %w[Português pt-BR]], choices.values.map { [it["aria-label"], it[:lang]] })
    end
  end

  describe "selector across the site" do
    it "pairs the site pages too" do
      { "/" => "/pt/", "/tags" => "/pt/tags", "/about" => "/pt/about",
        "/tag/ruby/" => "/pt/tag/ruby/" }.each do |en, pt|
        html get en

        assert_equal pt, choices["PT"][:href], en
      end
    end

    # A redirect would replace the address the reader mistyped, and the other language's
    # 404 is no translation of a missing page.
    it "is left out of the 404 pages, with no hreflang or redirect" do
      ["/404.html", "/pt/404.html"].each do |path|
        html get path

        assert_nil selector, path
        assert_empty alternates, path
        assert_nil document.query_selector("script[data-language-redirect]"), path
      end
    end

    it "is left out where there is no translation" do
      html get PAGY

      assert_nil selector
    end
  end

  describe "browser language" do
    it "has a script that can send the reader to their language, where there is a translation" do
      html get GEMS

      script = document.query_selector("head script[data-language-redirect]")

      assert_includes script.text, "navigator.languages"
      assert_equal "en", document.query_selector("html")["data-locale"]

      html get PAGY

      assert_nil document.query_selector("head script[data-language-redirect]")
    end

    it "runs before the stylesheet, so the page doesn't flash in the other language" do
      html get GEMS

      children = document.query_selector("head").children.to_a
      script = children.index { it.name == "script" && it["data-language-redirect"] }
      stylesheet = children.index { it.name == "link" && it[:rel] == "stylesheet" }

      assert_operator script, :<, stylesheet
    end
  end

  describe "head" do
    it "lists both versions with hreflang, English as the default" do
      html get GEMS_PT

      assert_equal({ "en" => "#{SITE}#{GEMS}", "pt-BR" => "#{SITE}#{GEMS_PT}", "x-default" => "#{SITE}#{GEMS}" },
                   alternates)
    end

    it "has no hreflang links where there is no translation" do
      html get PAGY

      assert_empty alternates
    end

    it "sets og:locale to the page's language, with the other as an alternate" do
      html get GEMS

      assert_equal [["en_US"], ["pt_BR"]], [meta("og:locale"), meta("og:locale:alternate")]

      html get GEMS_PT

      assert_equal [["pt_BR"], ["en_US"]], [meta("og:locale"), meta("og:locale:alternate")]
    end

    it "describes the Portuguese home in Portuguese" do
      html get "/pt/"

      assert_equal ["Um diário de aventuras sobre software, ofício e IA."], meta("og:description")
    end
  end
end
