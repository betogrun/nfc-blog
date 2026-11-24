require "minitest_helper"

class TestLayout < Bridgetown::Test
  READING_TIMES = YAML.load_file(File.expand_path("fixtures/reading_times.yml", __dir__))

  describe "navigation" do
    it "inlines its icons so CSS can color them" do
      html get "/"

      icon = document.query_selector(".header-links a[title='GitHub'] svg.icon-github")

      refute_nil icon.query_selector("path")
    end

    it "has a theme toggle" do
      html get "/"

      refute_nil document.query_selector(".header-links [data-theme-toggle]")
    end
  end

  describe "article meta" do
    it "shows the date and tag names linking to tag pages" do
      html get "/posts/overwriting-pagy-navigation-helper"

      meta = document.query_selector(".article-header .article-list-footer")

      assert_includes meta.text, "July 11, 2024"
      tag_names = meta.query_selector_all(".article-list-tags a").map { it.text.strip }

      assert_equal ["Rails", "Pagy", "Tailwind CSS", "Daisy UI"], tag_names
      assert_equal "/tag/pagy/", meta.query_selector("a[href*='pagy']")[:href]
    end

    READING_TIMES.each do |slug, minutes|
      it "keeps the Jekyll reading time for #{slug}" do
        html get "/posts/#{slug}"

        assert_includes document.query_selector(".article-list-minutes").text, "#{minutes} minute read"
      end
    end
  end

  describe "comments" do
    it "keys the Disqus thread by the post path and canonical URL" do
      html get "/posts/overwriting-pagy-navigation-helper"

      thread = document.query_selector("#disqus_thread")

      assert_equal "notesfromacoder", thread["data-disqus-shortname"]
      assert_equal "/posts/overwriting-pagy-navigation-helper", thread["data-disqus-identifier"]
      assert_equal "https://blog.albertorocha.me/posts/overwriting-pagy-navigation-helper", thread["data-disqus-url"]
    end
  end

  describe "home" do
    it "lists four posts with their meta" do
      html get "/"

      assert_equal 4, document.query_selector_all(".article-list-item .article-list-footer").size
    end
  end
end
