require "minitest_helper"

class TestPostPage < Bridgetown::Test
  READING_TIMES = YAML.load_file(File.expand_path("fixtures/reading_times.yml", __dir__))
  PAGY = "/posts/overwriting-pagy-navigation-helper".freeze

  def squish(text) = text.split.join(" ")

  describe "article meta" do
    it "shows the title, a dotted leader and the ISO date on one line in lists, like a contents page" do
      html get "/tag/pagy/"

      heading = document.query_selector(".article-list-item .article-list-heading")

      assert_equal "Overwriting the Pagy Navigation Helper", heading.query_selector("a[href='#{PAGY}'] h2").text.strip
      assert_equal "true", heading.query_selector(".article-list-leader")["aria-hidden"]
      assert_equal "2024-07-11", heading.query_selector("time").text.strip
      assert_equal "2024-07-11", heading.query_selector("time")[:datetime]
    end

    it "shows the reading time and tag names linking to tag pages under the description in lists" do
      html get "/tag/pagy/"

      meta = document.query_selector(".article-list-description + .article-meta")

      assert_equal "4 min · Rails, Pagy, Tailwind CSS, Daisy UI", squish(meta.text)
      assert_nil meta.query_selector("time")
      assert_equal "/tag/pagy/", meta.query_selector("a[href*='pagy']")[:href]
    end

    READING_TIMES.each do |slug, minutes|
      it "keeps the Jekyll reading time for #{slug}" do
        html get "/posts/#{slug}"

        assert_includes document.query_selector(".article-header .article-meta").text, "#{minutes} min"
      end
    end
  end

  describe "post header" do
    it "shows the meta line without tags above the title" do
      html get PAGY

      meta = document.query_selector(".article-header .article-meta")

      assert_equal "2024-07-11 · 4 min", squish(meta.text)
      assert_empty meta.query_selector_all("a")
    end
  end

  describe "post end" do
    it "files the post under its tags at the end" do
      html get PAGY

      filed = document.query_selector(".article-filed")

      assert_match(/\Afiled under Rails, Pagy, Tailwind CSS, Daisy UI\b/, squish(filed.text))
      assert_equal "/tag/rails/", filed.query_selector("a")[:href]
    end

    it "offers a native share button, hidden until JavaScript shows it" do
      html get PAGY

      share = document.query_selector(".article-filed .article-share[hidden] button[data-share]")

      assert_equal "https://blog.albertorocha.me#{PAGY}", share["data-share-url"]
      assert_equal "Overwriting the Pagy Navigation Helper", share["data-share-title"]
      assert_empty document.query_selector_all("a[href*='twitter.com/intent'], a[href*='x.com/intent']")
    end

    it "links to the older post and to the home" do
      html get PAGY

      links = document.query_selector_all(".article-nav a").map { [squish(it.text), it[:href]] }

      assert_equal [["← Renaming the default Git branch to main", "/posts/rename-git-master-to-main"],
                    ["Contents", "/"]], links
    end

    it "shows only the home link on the oldest post" do
      html get "/posts/feature-branch-workflow"

      assert_equal(["Contents"], document.query_selector_all(".article-nav a").map { squish(it.text) })
    end
  end

  describe "post body" do
    it "sets the opening phrase of the first paragraph in small caps" do
      html get "/posts/publishing-ruby-gems-with-github-actions"

      assert_equal "In this post,", document.query_selector(".article-content p:first-of-type .opening").text
    end
  end

  describe "comments" do
    it "keys the Disqus thread by the post path and canonical URL" do
      html get PAGY

      thread = document.query_selector("#disqus_thread")

      assert_equal "notesfromacoder", thread["data-disqus-shortname"]
      assert_equal PAGY, thread["data-disqus-identifier"]
      assert_equal "https://blog.albertorocha.me#{PAGY}", thread["data-disqus-url"]
    end
  end
end
