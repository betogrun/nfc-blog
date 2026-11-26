require "minitest_helper"

class TestAboutPage < Bridgetown::Test
  describe "about page" do
    it "shows the heading, then the cut-out photo beside the text" do
      html get "/about"

      photo = document.query_selector(".about h1 + picture .about-photo")

      assert_equal "About me", document.query_selector(".about h1").text.strip
      assert_equal ["/images/myself.png", "Alberto Rocha"], [photo[:src], photo[:alt]]
      assert_equal %w[190 286], [photo[:width], photo[:height]] # the file's 400×602, scaled
      assert_equal 3, document.query_selector_all(".about picture ~ p").length
    end

    # One <img> behind a <picture> source, so only the photo shown downloads: a second,
    # hidden <img> would download too. theme.js retargets the source's media query.
    it "has a light T-shirt variant of the photo for the dark theme" do
      html get "/about"

      source = document.query_selector(".about picture source[data-theme-source]")

      assert_equal 1, document.query_selector_all(".about img").length
      assert_equal ["/images/myself-dark-theme.png", "(prefers-color-scheme: dark)"],
                   [source[:srcset], source[:media]]
    end

    it "opens the text with its first words in small caps, like a post" do
      html get "/about"

      assert_equal "Hello!", document.query_selector(".about p:first-of-type .opening").text.strip
    end

    it "drops the old spacers and scroll-appear markup" do
      html get "/about"

      assert_empty document.query_selector_all(".about center, .about br, .scrollappear")
    end
  end
end
