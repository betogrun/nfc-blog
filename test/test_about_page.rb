require "minitest_helper"

class TestAboutPage < Bridgetown::Test
  describe "about page" do
    it "shows the heading, then the cut-out photo beside the text" do
      html get "/about"

      photo = document.query_selector(".about h1 + .about-photo")

      assert_equal "About me", document.query_selector(".about h1").text.strip
      assert_equal ["/images/myself.png", "Alberto Rocha"], [photo[:src], photo[:alt]]
      assert_equal %w[190 286], [photo[:width], photo[:height]] # the file's 400×602, scaled
      assert_equal 3, document.query_selector_all(".about .about-photo ~ p").length
    end

    it "has a white T-shirt variant of the photo for the dark theme" do
      html get "/about"

      photos = document.query_selector_all(".about .about-photo")
      dark = document.query_selector(".about .about-photo + .about-photo-dark")

      assert_equal 2, photos.length
      assert_equal ["/images/myself-white-shirt.png", "Alberto Rocha"], [dark[:src], dark[:alt]]
      assert_equal %w[190 286], [dark[:width], dark[:height]]
      assert_equal(%w[lazy lazy], photos.map { it[:loading] }) # only the shown one downloads
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
