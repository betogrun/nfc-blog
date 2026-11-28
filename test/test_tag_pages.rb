require "minitest_helper"

class TestTagPages < Bridgetown::Test
  describe "tag archive" do
    it "lists the posts tagged with it" do
      html get "/tag/pagy/"

      assert_includes document.query_selector("title").text, "Pagy"
      assert_includes document.query_selector_all("a").map { it[:href] },
                      "/posts/overwriting-pagy-navigation-helper"
    end
  end

  describe "tag page title" do
    it "is the tag's name and its post count, above the list" do
      html get "/tag/pagy/"

      header = document.query_selector(".tag-header")

      assert_equal "Pagy", header.query_selector("h1").text.strip
      assert_equal "1 post", header.query_selector(".tag-count").text.strip
      assert_equal "article-list", header.next_element[:class]
    end

    it "counts several posts in the plural" do
      html get "/tag/docker/"

      assert_equal "2 posts", document.query_selector(".tag-header .tag-count").text.strip
    end

    it "is there even when the tag has no posts" do
      html get "/tag/design/"

      assert_equal "Design", document.query_selector(".tag-header h1").text.strip
      assert_nil document.query_selector(".tag-header .tag-count")
    end
  end

  describe "tag archive pages" do
    it "exist for tags without posts, as on Jekyll" do
      html get "/tag/design/"

      assert_includes document.query_selector("body").text, "There are no posts in Design."
    end

    it "exists for every tag used by a post" do
      known = YAML.load_file(File.expand_path("../src/_data/tags.yml", __dir__)).keys
      used = Dir[File.expand_path("../src/_posts/*.md", __dir__)].flat_map do |path|
        YAML.safe_load(File.read(path)[/\A---\n(.*?)\n---/m, 1]).fetch("tags", [])
      end

      assert_empty used.uniq - known, "add these tags to src/_data/tags.yml"
    end
  end
end
