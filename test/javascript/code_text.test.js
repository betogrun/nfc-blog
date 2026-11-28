// What a code block's copy button puts on the clipboard (#143). Run with `npm test`.
import { test } from "node:test"
import assert from "node:assert/strict"

import { textToCopy } from "../../frontend/javascript/code_text.js"

// Turns Rouge's HTML for a block's <code> into the pieces the button reads: each text
// run in order, with `prompt` set on the spans Rouge marks `.gp`.
function rouge(html) {
  const unescape = (text) =>
    text.replaceAll("&lt;", "<").replaceAll("&gt;", ">").replaceAll("&quot;", '"').replaceAll("&amp;", "&")

  return html.split(/(<span class="\w+">[^<]*<\/span>)/).filter(Boolean).map((part) => {
    const span = part.match(/^<span class="(\w+)">([^<]*)<\/span>$/)
    return span ? { text: unescape(span[2]), prompt: span[1] === "gp" } : { text: unescape(part), prompt: false }
  })
}

test("console blocks copy their commands, without prompts, output or blank lines", () => {
  const code = rouge(
    '<span class="gp">$</span><span class="w"> </span>asdf <span class="nb">install</span> ruby 2.4.3\n' +
    '<span class="gp">$</span><span class="w"> </span>asdf <span class="nb">local</span> ruby 2.4.3\n' +
    "\n" +
    '<span class="gp">$</span><span class="w"> </span>ruby <span class="nt">-v</span>\n' +
    '<span class="go">ruby 2.4.3p205 (2017-12-14 revision 61247) [x86_64-linux]\n</span>'
  )

  assert.equal(textToCopy("console", code), "asdf install ruby 2.4.3\nasdf local ruby 2.4.3\nruby -v")
})

test("console blocks drop trailing spaces after a command", () => {
  const code = rouge('<span class="gp">$</span><span class="w"> </span>git fetch upstream \n')

  assert.equal(textToCopy("console", code), "git fetch upstream")
})

// Without `?prompt=$`, Rouge reads output with `#`, `>` or `->` as a prompt.
test("console blocks ignore output that Rouge marks as a prompt", () => {
  const code = rouge(
    '<span class="gp">$</span><span class="w"> </span>git push origin test-branch\n' +
    '<span class="go">app/models/user.rb:9:3: C: Missing space after #.\n</span>' +
    '<span class="gp">  #</span>another\n' +
    '<span class="gp"> * [new branch]      test-branch -&gt;</span> test-branch\n' +
    '<span class="gp">   7e5e502..588a4df  master     -&gt;</span> upstream/master\n'
  )

  assert.equal(textToCopy("console", code), "git push origin test-branch")
})

test("console blocks accept a user@host:path prompt and a zsh % prompt", () => {
  const code = rouge(
    '<span class="gp">deploy@web:~/app$</span><span class="w"> </span>bin/rails db:migrate\n' +
    '<span class="gp">%</span><span class="w"> </span>bundle install\n'
  )

  assert.equal(textToCopy("console", code), "bin/rails db:migrate\nbundle install")
})

test("console commands ending in a backslash carry on to the next line", () => {
  const code = rouge(
    '<span class="gp">$</span><span class="w"> </span>docker run <span class="se">\\</span>\n' +
    "  --rm hello-world\n" +
    '<span class="go">Hello from Docker!\n</span>'
  )

  assert.equal(textToCopy("console", code), "docker run \\\n  --rm hello-world")
})

test("console blocks without a prompt are copied as they are", () => {
  const code = rouge('<span class="go"> git branch --move master main\n</span>')

  assert.equal(textToCopy("console", code), " git branch --move master main")
})

test("shell blocks lose a leading $ and keep every line", () => {
  const code = rouge(
    'touch new_file.txt <span class="c">#Create or modify a file</span>\n' +
    '<span class="nv">$ </span>git add new_file.txt\n' +
    '<span class="nv">$ </span>sudo usermod <span class="nt">-aG</span> docker <span class="nv">$USER</span>\n'
  )

  for (const language of ["bash", "shell", "sh", "zsh"]) {
    assert.equal(
      textToCopy(language, code),
      "touch new_file.txt #Create or modify a file\ngit add new_file.txt\nsudo usermod -aG docker $USER"
    )
  }
})

test("other blocks are copied exactly, without the final newline", () => {
  const code = rouge(
    '<span class="k">def</span> <span class="nf">nav</span>\n' +
    '  <span class="s2">"$ not a prompt"</span>\n' +
    '<span class="k">end</span>\n'
  )

  assert.equal(textToCopy("ruby", code), 'def nav\n  "$ not a prompt"\nend')
  assert.equal(textToCopy(undefined, code), 'def nav\n  "$ not a prompt"\nend')
})
