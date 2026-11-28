// Native share button: the system share sheet where the browser has one (Web Share API),
// otherwise it copies the post's URL. Hidden in the HTML, so it only shows when it can work.
const MESSAGE_FOR = 2000

export function setupShareButtons() {
  if (!navigator.share && !navigator.clipboard) return

  document.querySelectorAll("[data-share]").forEach((button) => {
    const { shareTitle: title, shareUrl: url, shareCopied: copied, shareFailed: failed } = button.dataset
    const label = button.textContent

    const say = (message) => {
      button.textContent = message
      setTimeout(() => { button.textContent = label }, MESSAGE_FOR)
    }

    const copy = async () => {
      try {
        await navigator.clipboard.writeText(url)
        say(copied)
      } catch {
        say(failed)
      }
    }

    button.addEventListener("click", async () => {
      if (!navigator.share) return copy()

      try {
        await navigator.share({ title, url })
      } catch (error) {
        // AbortError: the reader closed the share sheet. Anything else: copy instead.
        if (error.name !== "AbortError") await copy()
      }
    })
    button.closest("[hidden]")?.removeAttribute("hidden")
  })
}
