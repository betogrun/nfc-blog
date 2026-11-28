// A copy button on every code block in a post (#143). Added here rather than in the HTML,
// so it only shows where the Clipboard API can work. Labels come from the post body's
// data- attributes, rendered from the locale files; what gets copied is in code_text.js.
import { textToCopy } from "./code_text"

const MESSAGE_FOR = 2000

export function setupCopyButtons() {
  if (!navigator.clipboard) return

  document.querySelectorAll("[data-copy]").forEach((content) => {
    const { copy: label, copyCopied: copied, copyFailed: failed } = content.dataset

    content.querySelectorAll("div.highlighter-rouge").forEach((block) => {
      const code = block.querySelector("code")
      if (!code) return

      const button = document.createElement("button")
      button.type = "button"
      button.className = "code-copy"
      button.textContent = label
      button.setAttribute("aria-live", "polite")

      let timer
      const say = (message) => {
        button.textContent = message
        clearTimeout(timer)
        timer = setTimeout(() => { button.textContent = label }, MESSAGE_FOR)
      }

      button.addEventListener("click", async () => {
        try {
          await navigator.clipboard.writeText(textToCopy(languageOf(block), piecesOf(code)))
          say(copied)
        } catch {
          say(failed)
        }
      })

      block.prepend(button)
    })
  })
}

// Kramdown sets the fence's language as a `language-<name>` class on the wrapper.
function languageOf(block) {
  return [...block.classList].find((name) => name.startsWith("language-"))?.slice("language-".length)
}

function piecesOf(code) {
  return [...code.childNodes].map((node) => ({
    text: node.textContent,
    prompt: node.nodeType === Node.ELEMENT_NODE && node.classList.contains("gp")
  }))
}
