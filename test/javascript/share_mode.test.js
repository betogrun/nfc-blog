// What the share button does (#145): the system share sheet on phones, the row of share
// links everywhere else. Run with `npm test`.
import { test } from "node:test"
import assert from "node:assert/strict"

import { shareMode } from "../../frontend/javascript/share_mode.js"

test("phones with the Web Share API open the system share sheet", () => {
  assert.equal(shareMode({ webShare: true, coarsePointer: true }), "sheet")
})

test("desktops show the row, even where the browser has the Web Share API", () => {
  assert.equal(shareMode({ webShare: true, coarsePointer: false }), "row")
  assert.equal(shareMode({ webShare: false, coarsePointer: false }), "row")
})

test("phones without the Web Share API (older browsers, plain HTTP) show the row", () => {
  assert.equal(shareMode({ webShare: false, coarsePointer: true }), "row")
})
