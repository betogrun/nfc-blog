// The share button (#145). On phones (a coarse pointer and the Web Share API) it opens the
// system share sheet, falling back to copying the post's URL. Everywhere else it shows and
// hides the row of share links under it (the ShareLinks component), where "copy link"
// copies the URL. Hidden in the HTML, so it only shows when JavaScript runs.
import { shareMode } from "./share_mode"

const MESSAGE_FOR = 2000

// Shows a message in place of a button's label for a moment.
function say(button, message) {
  button.dataset.label ??= button.textContent
  button.textContent = message
  clearTimeout(button.sayTimer)
  button.sayTimer = setTimeout(() => { button.textContent = button.dataset.label }, MESSAGE_FOR)
}

async function copy(button) {
  const { shareUrl: url, shareCopied: copied, shareFailed: failed } = button.dataset

  try {
    await navigator.clipboard.writeText(url)
    say(button, copied)
  } catch {
    say(button, failed)
  }
}

const usesShareSheet = () =>
  shareMode({ webShare: Boolean(navigator.share), coarsePointer: matchMedia("(pointer: coarse)").matches }) === "sheet"

export function setupShareButtons() {
  document.querySelectorAll("[data-share-copy]").forEach((button) => {
    if (!navigator.clipboard) return button.closest("li").remove()

    button.addEventListener("click", () => copy(button))
  })

  document.querySelectorAll("[data-share]").forEach((button) => {
    const row = document.getElementById(button.getAttribute("aria-controls"))

    if (usesShareSheet()) {
      button.removeAttribute("aria-expanded")
      button.removeAttribute("aria-controls")
      button.addEventListener("click", async () => {
        const { shareTitle: title, shareUrl: url } = button.dataset

        try {
          await navigator.share({ title, url })
        } catch (error) {
          // AbortError: the reader closed the share sheet. Anything else: copy instead.
          if (error.name !== "AbortError" && navigator.clipboard) await copy(button)
        }
      })
    } else {
      button.removeAttribute("aria-live")
      button.addEventListener("click", () => {
        const open = button.getAttribute("aria-expanded") !== "true"
        button.setAttribute("aria-expanded", open)
        row.hidden = !open
      })
    }
    button.closest("[hidden]")?.removeAttribute("hidden")
  })
}
