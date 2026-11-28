# Sends the reader to the page in their language, before the first paint. It runs only on
# pages that have a translation, and reads the versions from the hreflang links above it.
#
# A language chosen in the selector is saved (frontend/javascript/language.js) and always
# wins. Without one, a browser that prefers Portuguese over English goes from an English
# page to its Portuguese version; other readers stay on the page they opened. The path is
# kept relative, so previews and the dev server stay on their own host.
class LanguageRedirect < Bridgetown::Component
  SCRIPT = <<~JS.freeze
    try {
      const page = document.documentElement.dataset.locale
      const saved = localStorage.getItem("locale")
      const browser = (navigator.languages || [navigator.language])
        .map((language) => language.slice(0, 2).toLowerCase())
        .find((language) => language === "en" || language === "pt")
      const wanted = saved || (browser === "pt" ? "pt" : null)
      const version = wanted && wanted !== page &&
        document.querySelector(`link[rel="alternate"][hreflang^="${wanted}"]`)
      if (version) location.replace(new URL(version.href).pathname + location.search + location.hash)
    } catch {}
  JS

  def template
    <<~HTML.html_safe
      <script data-language-redirect>
      #{SCRIPT}</script>
    HTML
  end
end
