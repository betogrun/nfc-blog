// The saved choice is applied before first paint by an inline script in the
// <head> (see src/_partials/_head.erb). Without one, CSS follows the OS setting.
const root = document.documentElement
const prefersDark = window.matchMedia("(prefers-color-scheme: dark)")

const currentTheme = () => root.dataset.theme || (prefersDark.matches ? "dark" : "light")

export function setupThemeToggle() {
  document.querySelectorAll("[data-theme-toggle]").forEach((toggle) => {
    toggle.addEventListener("click", (event) => {
      event.preventDefault()
      const theme = currentTheme() === "dark" ? "light" : "dark"
      root.dataset.theme = theme
      localStorage.setItem("theme", theme)
    })
  })
}
