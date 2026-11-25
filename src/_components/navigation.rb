# The header bar (site links, name, reader preferences) and the outside links the footer
# shows as icons. `links` is the single source for those outside links.
class Navigation < Bridgetown::Component
  Link = Data.define(:icon, :title, :href, :external)

  SITE_LINKS = { "Tags" => "/tags", "About" => "/about" }.freeze

  def initialize(metadata:)
    @metadata = metadata
  end

  def site_links = SITE_LINKS

  def links
    social = @metadata.social

    [
      Link.new("github", "GitHub", "https://github.com/#{social.github}", true),
      Link.new("linkedin", "LinkedIn", "https://www.linkedin.com/in/#{social.linkedin}", true),
      Link.new("x", "X", "https://x.com/#{social.x}", true),
      Link.new("email", "Email", "mailto:#{@metadata.email}", false),
      Link.new("rss", "RSS feed", "/feed.xml", true)
    ]
  end
end
