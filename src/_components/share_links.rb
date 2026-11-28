require "erb"

# The row of share links the share button discloses on desktops (#145): copy link, then
# each network's own share page and email, built from the post's title and absolute URL.
# Phones keep the system share sheet (frontend/javascript/share.js). No third-party
# scripts and no tracking parameters; Mastodon is left out, as it needs the reader's instance.
class ShareLinks < Bridgetown::Component
  ID = "share-links".freeze

  def self.id = ID

  Link = Data.define(:name, :href) do
    def external? = href.start_with?("https://")
  end

  def self.links(title:, url:, email: "email")
    title = ERB::Util.url_encode(title)
    url = ERB::Util.url_encode(url)
    [
      Link.new("LinkedIn", "https://www.linkedin.com/sharing/share-offsite/?url=#{url}"),
      Link.new("Bluesky", "https://bsky.app/intent/compose?text=#{title}%20#{url}"),
      Link.new("X", "https://x.com/intent/post?text=#{title}&url=#{url}"),
      Link.new("Hacker News", "https://news.ycombinator.com/submitlink?u=#{url}&t=#{title}"),
      Link.new("Reddit", "https://www.reddit.com/submit?url=#{url}&title=#{title}"),
      Link.new(email, "mailto:?subject=#{title}&body=#{url}")
    ]
  end

  def initialize(title:, url:)
    @title = title
    @url = url
  end

  def links = self.class.links(title: @title, url: @url, email: I18n.t("post.email"))
end
