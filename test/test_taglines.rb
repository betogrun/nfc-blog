require "minitest_helper"

# The subtitle under the masthead rotates through `taglines` in site_metadata.yml (#118).
class TestTaglines < Minitest::Test
  METADATA = YAML.load_file(File.expand_path("../src/_data/site_metadata.yml", __dir__))
  TAGLINES = METADATA.fetch("taglines", [])
  TAGLINES_PT = METADATA.dig("pt", "taglines") || []

  # The list is rolled like a die, and the subtitle's title says so ("rolled a 3 on a d8").
  DIE_SIZES = [4, 6, 8, 10, 12, 20].freeze

  # The masthead is sized for the longest tagline. The longest today is 64 characters;
  # a longer one could wrap onto another line and make the header height change from one
  # visit to the next, so a new tagline has to fit in about the same space.
  MAX_LENGTH = 65

  def test_count_is_a_die_size
    assert_includes DIE_SIZES, TAGLINES.size
  end

  # The Portuguese home rolls the same die, so a roll picks the same line in both.
  def test_portuguese_has_one_tagline_per_english_one
    assert_equal TAGLINES.size, TAGLINES_PT.size
  end

  def test_every_tagline_fits_the_masthead
    (TAGLINES + TAGLINES_PT).each do |tagline|
      assert_operator tagline.size, :<=, MAX_LENGTH, tagline
    end
  end

  # The page's HTML always carries the main subtitle, so it is also what search results
  # and share cards show.
  def test_main_subtitle_is_the_first_tagline_and_the_site_description
    assert_equal "An adventure log on software, craft and AI.", TAGLINES.first
    assert_equal TAGLINES.first, METADATA.fetch("description")
    assert_equal TAGLINES_PT.first, METADATA.dig("pt", "description")
  end
end
