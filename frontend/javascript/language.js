// Saves the language picked in the selector, so the redirect script in the <head>
// (src/_components/language_redirect.rb) keeps the reader in it.
export function setupLanguageChoice() {
  document.querySelectorAll(".language-nav [data-locale]").forEach((link) => {
    link.addEventListener("click", () => {
      try {
        localStorage.setItem("locale", link.dataset.locale)
      } catch {}
    })
  })
}
