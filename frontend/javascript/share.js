// Native share button: the system share sheet where the browser has one (Web Share API),
// otherwise it copies the post's URL. Hidden in the HTML, so it only shows when it can work.
const COPIED_FOR = 2000

export function setupShareButtons() {
  if (!navigator.share && !navigator.clipboard) return

  document.querySelectorAll("[data-share]").forEach((button) => {
    const { shareTitle: title, shareUrl: url } = button.dataset
    const label = button.textContent

    button.addEventListener("click", async () => {
      if (navigator.share) {
        try {
          await navigator.share({ title, url })
        } catch {
          // The reader closed the share sheet.
        }
        return
      }

      try {
        await navigator.clipboard.writeText(url)
        button.textContent = "link copied"
        setTimeout(() => { button.textContent = label }, COPIED_FOR)
      } catch {
        // Clipboard access denied: nothing to report.
      }
    })
    button.closest("[hidden]")?.removeAttribute("hidden")
  })
}
