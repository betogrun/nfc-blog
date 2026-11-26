require "minitest_helper"

class TestAboutPage < Bridgetown::Test
  describe "about page" do
    it "shows the round photo, then the heading, then the text" do
      html get "/about"

      photo = document.query_selector(".about .about-photo")

      assert_equal "/images/myself.png", photo[:src]
      assert_equal "Alberto Rocha", photo[:alt]
      assert_equal "About me", document.query_selector(".about .about-photo + h1").text.strip
      assert_equal 3, document.query_selector_all(".about h1 ~ p").length
    end

    it "drops the old spacers and scroll-appear markup" do
      html get "/about"

      assert_empty document.query_selector_all(".about center, .about br, .scrollappear")
    end
  end
end
