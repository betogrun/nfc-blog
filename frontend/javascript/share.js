// Opens share links in a small popup instead of a new tab.
export function setupSharePopups() {
  document.querySelectorAll(".article-share a").forEach((link) => {
    link.addEventListener("click", (event) => {
      event.preventDefault()
      window.open(link.href, "Share", "width=200,height=200,noopener")
    })
  })
}
