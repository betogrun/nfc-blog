// The saved choice is applied before first paint by an inline script in the
// <head> (see src/_partials/_head.erb). Without one, CSS follows the OS setting.
const root = document.documentElement
const prefersDark = window.matchMedia("(prefers-color-scheme: dark)")

const currentTheme = () => root.dataset.theme || (prefersDark.matches ? "dark" : "light")

export function setupThemeToggle() {
  const toggles = document.querySelectorAll("[data-theme-toggle]")
  const label = () => {
    const next = currentTheme() === "dark" ? "light" : "dark"
    toggles.forEach((toggle) => toggle.setAttribute("aria-label", `Switch to ${next} theme`))
  }

  toggles.forEach((toggle) => {
    toggle.addEventListener("click", () => {
      const theme = currentTheme() === "dark" ? "light" : "dark"
      root.dataset.theme = theme
      localStorage.setItem("theme", theme)
      label()
    })
  })
  prefersDark.addEventListener("change", label)
  label()
}
