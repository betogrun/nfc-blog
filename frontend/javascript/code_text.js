// What a code block's copy button puts on the clipboard (#143). Kept apart from the DOM so
// test/javascript/code_text.test.js can run it under `node --test`.
//
// `language` is the fence's language (`console`, `ruby`, ...). `pieces` are the text runs of
// the block's <code> in order, as { text, prompt }, with `prompt` set on the spans Rouge
// marks `.gp`.

// Shell scripts in posts often show a `$ ` before commands, mixed with lines that have none
// (`touch file` then `$ git add file`), so these lose the prompt and keep every line.
const SHELLS = new Set(["bash", "shell", "sh", "zsh"])

// A shell prompt, `$` or `%`, maybe after a `user@host:path` with no spaces. Without
// `?prompt=$` Rouge guesses prompts, and marks output such as `  #another` as `.gp` too.
const PROMPT = /^\S*[$%]$/

export function textToCopy(language, pieces) {
  const text = pieces.map((piece) => piece.text).join("").replace(/\n$/, "")

  if (language === "console") return commands(pieces) ?? text
  if (SHELLS.has(language)) return text.replace(/^\$ /gm, "")
  return text
}

// The commands of a console session: the lines that start with a prompt, without it, and
// none of the output. A command ending in `\` carries on to the next line. Returns null for
// a block without any prompt, which is copied as it is.
function commands(pieces) {
  const lines = [{ prompt: false, text: "" }]

  pieces.forEach((piece) => {
    const isPrompt = piece.prompt && PROMPT.test(piece.text)

    piece.text.split("\n").forEach((part, index) => {
      if (index > 0) lines.push({ prompt: false, text: "" })
      const line = lines.at(-1)

      if (isPrompt && line.text.trim() === "") {
        line.prompt = true
        line.text = ""
      } else {
        line.text += part
      }
    })
  })

  if (!lines.some((line) => line.prompt)) return null

  const kept = []
  let continues = false
  lines.forEach((line) => {
    if (line.prompt) kept.push(line.text.trim())
    else if (continues) kept.push(line.text)
    else return
    continues = kept.at(-1).trimEnd().endsWith("\\")
  })
  return kept.join("\n")
}
