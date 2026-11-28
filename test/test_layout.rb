require "minitest_helper"

class TestLayout < Bridgetown::Test
  PAGY = "/posts/overwriting-pagy-navigation-helper".freeze
  PER_PAGE = 8
  # English posts only: translations are named slug.pt.md.
  POST_COUNT = Dir[File.expand_path("../src/_posts/*.md", __dir__)].count do |path|
    !path.end_with?(".pt.md") && !File.read(path).match?(/^published: false$/)
  end
  PAGE_COUNT = (POST_COUNT / PER_PAGE.to_f).ceil

  describe "header" do
    it "puts the site links and the theme toggle on a line above the masthead" do
      html get PAGY

      bar = document.query_selector(".site-header > .site-bar")
      links = bar.query_selector_all(".site-nav a").to_h { [it.text.strip, it[:href]] }

      assert_equal({ "Tags" => "/tags", "About" => "/about" }, links)
      refute_nil bar.query_selector("button[data-theme-toggle]")
      assert_equal "site-masthead", bar.next_element[:class]
    end

    it "has the name, linking home, and a row of dots in the masthead" do
      html get PAGY

      name = document.query_selector(".site-masthead .site-name")

      assert_equal "/", name[:href]
      assert_equal "Reflections & Refactors", name.text.split.join(" ")
      assert_equal "&", name.query_selector(".site-name-amp").text
      assert_equal "true", document.query_selector(".site-masthead .site-dinkus")["aria-hidden"]
    end

    it "has a theme toggle button with an accessible name" do
      html get "/"

      toggle = document.query_selector(".site-header button[data-theme-toggle]")

      assert_equal "button", toggle[:type]
      refute_empty toggle["aria-label"]
      refute_nil toggle.query_selector("svg.icon-theme")
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

    it "opens with a row of dots instead of a rule, echoing the masthead" do
      html get "/"

      dinkus = document.query_selector(".site-footer > .site-dinkus:first-child")

      assert_equal "true", dinkus["aria-hidden"]
      assert_equal "· · ·", dinkus.text.strip
    end

    it "has the copyright line" do
      html get "/"

      assert_includes document.query_selector(".site-footer").text, "© #{Time.now.year} Alberto Rocha"
    end
  end

  describe "home" do
    it "lists eight posts with their meta" do
      html get "/"

      assert_equal [PER_PAGE, POST_COUNT].min, document.query_selector_all(".article-list-item .article-meta").size
    end
  end

  describe "pagination" do
    it "lists the rest on the next page" do
      html get "/posts/page/2/"

      assert_equal POST_COUNT - PER_PAGE, document.query_selector_all(".article-list-item").size
    end

    it "says which page this is between the older and newer links" do
      html get "/"

      pagination = document.query_selector("nav.article-pagination")

      assert_equal "page 1 of #{PAGE_COUNT}", pagination.query_selector(".article-pagination-count").text.strip
      assert_equal "/posts/page/2/", pagination.query_selector("a.article-pagination-older")[:href]
      assert_nil pagination.query_selector("a.article-pagination-newer")
    end
  end

  describe "home masthead" do
    it "shows the subtitle in the masthead only on the home" do
      html get PAGY

      assert_nil document.query_selector(".site-tagline")
    end

    it "shows the main subtitle between the name and the dots on the home" do
      html get "/"

      tagline = document.query_selector(".site-masthead .site-name + .site-tagline")

      assert_equal "An adventure log on software, craft and AI.", tagline.text
      assert_includes tagline.next_element.text, "The Dungeon Master is a language model now."
      assert_equal "site-dinkus", tagline.next_element.next_element[:class]
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
