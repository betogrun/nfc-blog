require "minitest_helper"

class TestPostPage < Bridgetown::Test
  READING_TIMES = YAML.load_file(File.expand_path("fixtures/reading_times.yml", __dir__))
  PAGY = "/posts/overwriting-pagy-navigation-helper".freeze

  def squish(text) = text.split.join(" ")

  describe "list item" do
    it "shows the title on its own line in lists, and the ISO date at the end of the meta line" do
      html get "/tag/pagy/"

      item = document.query_selector(".article-list-item")
      date = item.query_selector(".article-list-meta > time")

      assert_equal "Overwriting the Pagy Navigation Helper", item.query_selector("a[href='#{PAGY}'] h2").text.strip
      assert_equal %w[2024-07-11 2024-07-11], [date.text.strip, date[:datetime]]
      assert_empty item.query_selector_all(".article-list-leader")
    end

    it "shows the reading time and tag names linking to tag pages under the description in lists" do
      html get "/tag/pagy/"

      meta = document.query_selector(".article-list-description + .article-list-meta > .article-meta")

      assert_equal "4 min · Rails, Pagy, Tailwind CSS, Daisy UI", squish(meta.text)
      assert_nil meta.query_selector("time")
      assert_equal "/tag/pagy/", meta.query_selector("a[href*='pagy']")[:href]
    end

    # Phones put the tags on a line of their own, as Chalk did.
    it "groups the tag links in lists, after their own divider" do
      html get "/tag/pagy/"

      tags = document.query_selector(".article-list-meta .article-meta-divider + .article-meta-tags")

      hrefs = tags.query_selector_all("a").map { it[:href] }

      assert_equal %w[/tag/rails/ /tag/pagy/ /tag/tailwindcss/ /tag/daisyui/], hrefs
    end
  end

  describe "article meta" do
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

    # The copy buttons on code blocks are added by JavaScript (#143), which reads its
    # labels from the post body so they come from the locale files.
    {
      PAGY => ["Copy", "Copied", "Copy failed"],
      "/pt/posts/publishing-ruby-gems-with-github-actions" => ["Copiar", "Copiado", "Falha ao copiar"]
    }.each do |path, labels|
      it "hands the code copy button its labels in the page's language on #{path}" do
        html get path

        content = document.query_selector(".article-content")
        rendered = %w[data-copy data-copy-copied data-copy-failed].map { content[it] }

        assert_equal labels, rendered
      end
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
