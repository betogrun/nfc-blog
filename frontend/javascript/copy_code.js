// A copy button on every code block in a post (#143). Added here rather than in the HTML,
// so it only shows where the Clipboard API can work. Labels come from the post body's
// data- attributes, rendered from the locale files.
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
          await navigator.clipboard.writeText(textToCopy(block, code))
          say(copied)
        } catch {
          say(failed)
        }
      })

      block.prepend(button)
    })
  })
}

// Shell scripts in posts often show a `$ ` before commands, mixed with lines that have none
// (`touch file` then `$ git add file`), so these lose the prompt and keep every line.
const SHELLS = ["bash", "shell", "sh", "zsh"]

function textToCopy(block, code) {
  const text = code.textContent.replace(/\n$/, "")
  if (block.classList.contains("language-console")) return commands(code) ?? text
  if (SHELLS.some((shell) => block.classList.contains(`language-${shell}`))) return text.replace(/^\$ /gm, "")

  return text
}

// A shell prompt, `$` or `%`, maybe after a `user@host:path` with no spaces. Rouge guesses
// prompts, and also marks output such as `  #another` or `abc..def  master ->` as `.gp`.
const PROMPT = /^\S*[$%]$/

// The commands of a console session: the lines that start with a prompt, without it, and
// none of the output. A command ending in `\` carries on to the next line. Blocks without
// any prompt are copied as they are, so this returns null for them.
function commands(code) {
  const lines = [{ prompt: false, text: "" }]

  code.childNodes.forEach((node) => {
    const pieces = node.textContent.split("\n")
    const isPrompt = node.nodeType === Node.ELEMENT_NODE && node.classList.contains("gp") &&
      PROMPT.test(node.textContent)

    pieces.forEach((piece, index) => {
      if (index > 0) lines.push({ prompt: false, text: "" })
      const line = lines.at(-1)

      if (isPrompt && line.text.trim() === "") {
        line.prompt = true
        line.text = ""
      } else {
        line.text += piece
      }
    })
  })

  if (!lines.some((line) => line.prompt)) return null

  const kept = []
  let continues = false
  lines.forEach((line) => {
    if (line.prompt) {
      kept.push(line.text.trim())
    } else if (continues) {
      kept.push(line.text)
    } else {
      return
    }
    continues = kept.at(-1).trimEnd().endsWith("\\")
  })
  return kept.join("\n")
}
