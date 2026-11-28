// Loads Disqus with a path-based identifier, so a thread stays with its post if the domain changes.
export function setupDisqus() {
  const thread = document.getElementById("disqus_thread")
  if (!thread) return

  const { disqusShortname, disqusIdentifier, disqusUrl, disqusLanguage } = thread.dataset
  window.disqus_config = function () {
    this.page.identifier = disqusIdentifier
    this.page.url = disqusUrl
    this.language = disqusLanguage
  }

  const script = document.createElement("script")
  script.src = `https://${disqusShortname}.disqus.com/embed.js`
  script.dataset.timestamp = Date.now()
  script.async = true
  document.head.appendChild(script)
}
