// Saves the language picked in the selector, so the redirect script in the <head>
// (src/_components/language_redirect.rb) keeps the reader in it.
export function setupLanguageChoice() {
  document.querySelectorAll(".language-nav [data-locale]").forEach((link) => {
    const save = () => {
      try {
        localStorage.setItem("locale", link.dataset.locale)
      } catch {}
    }
    // auxclick covers the middle button, which opens the link in a new tab.
    link.addEventListener("click", save)
    link.addEventListener("auxclick", save)
  })
}
