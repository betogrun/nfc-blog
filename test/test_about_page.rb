require "minitest_helper"

class TestAboutPage < Bridgetown::Test
  describe "about page" do
    it "shows the heading, then the cut-out photo beside the text" do
      html get "/about"

      photo = document.query_selector(".about h1 + .about-photo")

      assert_equal "About me", document.query_selector(".about h1").text.strip
      assert_equal ["/images/myself.png", "Alberto Rocha"], [photo[:src], photo[:alt]]
      assert_equal %w[190 286], [photo[:width], photo[:height]] # the file's 300×452, scaled
      assert_equal 3, document.query_selector_all(".about .about-photo ~ p").length
    end

    it "drops the old spacers and scroll-appear markup" do
      html get "/about"

      assert_empty document.query_selector_all(".about center, .about br, .scrollappear")
    end
  end
end
