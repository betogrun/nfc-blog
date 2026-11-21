require "minitest_helper"

class TestTagPages < Bridgetown::Test
  describe "tag archive" do
    it "lists the posts tagged with it" do
      html get "/tag/pagy/"

      assert_includes document.query_selector("h1").text, "Pagy"
      assert_includes document.query_selector_all("a").map { it[:href] },
                      "/posts/overwriting-pagy-navigation-helper"
    end

    it "exists for tags without posts, as it did on Jekyll" do
      html get "/tag/design/"

      assert_includes document.query_selector("body").text, "There are no posts in design."
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
