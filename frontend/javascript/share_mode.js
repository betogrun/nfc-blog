// What the share button does (#145), kept apart from the DOM so `npm test` can run it.
// Phones (a coarse pointer) open the system share sheet when the browser has the Web Share
// API; everywhere else, including phones without it, the button shows the row of links.
export function shareMode({ webShare, coarsePointer }) {
  return webShare && coarsePointer ? "sheet" : "row"
}
