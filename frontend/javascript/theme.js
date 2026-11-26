// The saved choice is applied before first paint by an inline script in the
// <head> (see src/_partials/_head.erb). Without one, CSS follows the OS setting.
const root = document.documentElement
const prefersDark = window.matchMedia("(prefers-color-scheme: dark)")

const currentTheme = () => root.dataset.theme || (prefersDark.matches ? "dark" : "light")

// A <picture> source marked data-theme-source holds the dark theme's image and follows
// the OS setting; point it at an explicit choice instead (see src/about.erb).
const syncThemeSources = () => {
  if (!root.dataset.theme) return
  document.querySelectorAll("[data-theme-source]").forEach((source) => {
    source.media = root.dataset.theme === "dark" ? "all" : "not all"
  })
}

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
      syncThemeSources()
      label()
    })
  })
  prefersDark.addEventListener("change", label)
  syncThemeSources()
  label()
}
