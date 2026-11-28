# The home's subtitle, in the masthead under the name. The HTML carries the main subtitle
# (the first tagline), which stays when JavaScript is off. The script right after it rolls
# one tagline per visit, keeps the roll in sessionStorage and swaps the text before the
# first paint, so nothing flickers. Its title gives the roll away: "rolled a 3 on a d8",
# from `rolled`, where {roll} and {sides} stand for the numbers.
class Tagline < Bridgetown::Component
  # Characters that could close the script or open an HTML comment inside it. They become
  # \u escapes, which JSON (and so JavaScript) reads back as the same characters.
  UNSAFE_IN_SCRIPT = /[<>&\u2028\u2029]/

  ROLLED = "rolled a {roll} on a d{sides}".freeze

  # %<taglines>s and %<rolled>s are JSON literals.
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
      tagline.title = %<rolled>s.replace("{roll}", roll).replace("{sides}", taglines.length)
    } catch {}
  JS

  def initialize(taglines:, rolled: ROLLED)
    @taglines = taglines
    @rolled = rolled
  end

  def template
    <<~HTML.html_safe
      <p class="site-tagline">#{ERB::Util.html_escape(@taglines.first)}</p>
      <script>
      #{format(SCRIPT, taglines: script_json(@taglines), rolled: script_json(@rolled))}</script>
    HTML
  end

  private

  def script_json(value) = JSON.generate(value).gsub(UNSAFE_IN_SCRIPT) { format("\\u%04x", it.ord) }
end
