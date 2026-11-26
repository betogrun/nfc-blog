require "minitest_helper"
# Tests serve the built site and never boot its autoloader, so load the component directly.
require_relative "../src/_components/tagline"

class TestTagline < Minitest::Test
  def render(taglines) = Nokolexbor::DocumentFragment.parse(Tagline.new(taglines:).template)

  # The list as the script sees it: the JSON literal assigned in the script.
  def embedded_list(fragment)
    JSON.parse(fragment.at_css("script").text[/taglines = (.*)$/, 1])
  end

  def test_renders_the_main_subtitle_so_it_shows_without_javascript
    fragment = render(["An adventure log.", "Session notes."])

    assert_equal "An adventure log.", fragment.at_css("p.site-tagline").text
  end

  def test_follows_the_subtitle_with_a_script_holding_every_tagline
    fragment = render(["An adventure log.", "Session notes."])

    assert_equal "script", fragment.at_css("p.site-tagline").next_element.name
    assert_equal ["An adventure log.", "Session notes."], embedded_list(fragment)
  end

  def test_escapes_the_subtitle_as_html
    fragment = render(["Tom & Jerry <b>", "Other"])

    assert_equal "Tom & Jerry <b>", fragment.at_css("p.site-tagline").text
    assert_nil fragment.at_css("p.site-tagline b")
  end

  # A tagline must not be able to close the script or open an HTML comment inside it.
  def test_escapes_the_embedded_list
    taglines = ["Main", "</script><script>alert(1)</script>", "<!-- &  "]
    html = Tagline.new(taglines:).template

    assert_equal 1, html.scan("</script>").size
    refute_includes html, "<!--"
    assert_equal taglines, embedded_list(render(taglines))
  end

  def test_rolls_once_per_visit_and_says_which_face_came_up
    script = render(%w[A B]).at_css("script").text

    assert_includes script, "sessionStorage"
    assert_includes script, "rolled a ${roll} on a d${taglines.length}"
  end
end
