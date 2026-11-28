require "minitest_helper"

# The ways to the About page (#141): the byline under the name and a link in the footer.
# On the About page itself both mark it as the current page instead of linking to it.
class TestAboutLinks < Bridgetown::Test
  PAGY = "/posts/overwriting-pagy-navigation-helper".freeze

  describe "byline" do
    it "signs the masthead with the author's name, linking to About" do
      html get PAGY

      byline = document.query_selector(".site-masthead .site-name + .site-byline")
      link = byline.query_selector("a")

      assert_equal "by Alberto Rocha", byline.text.split.join(" ")
      assert_equal ["/about", "author", "Alberto Rocha"], [link[:href], link[:rel], link.text.strip]
    end

    it "doesn't link the byline on the About page itself" do
      html get "/about"

      byline = document.query_selector(".site-byline")

      assert_nil byline.query_selector("a")
      assert_equal "Alberto Rocha", byline.query_selector("[aria-current='page']").text.strip
    end
  end

  describe "footer" do
    it "links to About between the row of dots and the icons" do
      html get "/"

      about = document.query_selector(".site-footer > .site-dinkus + a.site-footer-about")

      assert_equal ["/about", "About"], [about[:href], about.text.strip]
      assert_equal "nav", about.next_element.name
    end

    it "marks About as the current page on the About page" do
      html get "/about"

      about = document.query_selector(".site-footer .site-footer-about")

      assert_equal %w[span page], [about.name, about["aria-current"]]
    end
  end
end
