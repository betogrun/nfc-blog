# The subtitle under the site name. The HTML carries the main subtitle (the first tagline),
# which stays when JavaScript is off. The script right after it rolls one tagline per visit,
# keeps the roll in sessionStorage and swaps the text before the first paint, so nothing
# flickers. Its title gives the roll away: "rolled a 3 on a d8".
class Tagline < Bridgetown::Component
  # Characters that could close the script or open an HTML comment inside it. They become
  # \u escapes, which JSON (and so JavaScript) reads back as the same characters.
  UNSAFE_IN_SCRIPT = /[<>&\u2028\u2029]/

  # %<taglines>s is the JSON list; `${...}` is JavaScript interpolation.
  SCRIPT = <<~JS.freeze
    try {
      const taglines = %<taglines>s
      let roll = Number(sessionStorage.getItem("tagline-roll"))
      if (!(Number.isInteger(roll) && roll >= 1 && roll <= taglines.length)) {
        roll = Math.floor(Math.random() * taglines.length) + 1
        sessionStorage.setItem("tagline-roll", roll)
      }
      const tagline = document.currentScript.previousElementSibling
      tagline.textContent = taglines[roll - 1]
      tagline.title = `rolled a ${roll} on a d${taglines.length}`
    } catch {}
  JS

  def initialize(taglines:)
    @taglines = taglines
  end

  def template
    <<~HTML.html_safe
      <p class="header-tagline">#{ERB::Util.html_escape(@taglines.first)}</p>
      <script>
      #{format(SCRIPT, taglines: taglines_json)}</script>
    HTML
  end

  private

  def taglines_json = JSON.generate(@taglines).gsub(UNSAFE_IN_SCRIPT) { format("\\u%04x", it.ord) }
end
