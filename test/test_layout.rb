require "minitest_helper"

class TestLayout < Bridgetown::Test
  PAGY = "/posts/overwriting-pagy-navigation-helper".freeze

  describe "header" do
    it "puts the site links on the left and the name, linking home, in the center" do
      html get PAGY

      header = document.query_selector(".site-header")
      links = header.query_selector_all(".site-nav a").to_h { [it.text.strip, it[:href]] }

      assert_equal({ "Tags" => "/tags", "About" => "/about" }, links)
      assert_equal "/", header.query_selector(".site-name")[:href]
      assert_equal "Reflections & Refactors", header.query_selector(".site-name").text.strip
    end

    it "has a theme toggle button with an accessible name" do
      html get "/"

      toggle = document.query_selector(".site-header button[data-theme-toggle]")

      assert_equal "button", toggle[:type]
      refute_empty toggle["aria-label"]
      refute_nil toggle.query_selector("svg.icon-theme")
    end

    it "adds the subtitle under the bar only on the home" do
      html get PAGY

      assert_nil document.query_selector(".site-tagline")
    end

    it "shows the main subtitle under the bar on the home" do
      html get "/"

      tagline = document.query_selector(".site-header + main .site-tagline")

      assert_equal "An adventure log on software, craft and AI.", tagline.text
      assert_includes tagline.next_element.text, "The Dungeon Master is a language model now."
    end
  end

  describe "footer" do
    it "shows the outside links as labelled icons" do
      html get "/"

      links = document.query_selector_all(".site-footer nav a")

      assert_equal(["GitHub", "LinkedIn", "X", "Email", "RSS feed"], links.map { it["aria-label"] })
      assert_equal "https://x.com/betogrun", links[2][:href]
      links.each { refute_nil it.query_selector("svg path") }
    end

    it "has the copyright line" do
      html get "/"

      assert_includes document.query_selector(".site-footer").text, "© #{Time.now.year} Alberto Rocha"
    end
  end

  describe "home" do
    it "lists four posts with their meta" do
      html get "/"

      assert_equal 4, document.query_selector_all(".article-list-item .article-meta").size
    end
  end

  describe "scroll-appear" do
    it "is gone from the templates" do
      [PAGY, "/", "/tag/pagy/", "/tags"].each do |path|
        html get path

        assert_empty document.query_selector_all(".scrollappear"), path
      end
    end
  end
end
