# The header: a line with the site links and reader preferences, then the centered
# masthead (the name, the rolled tagline on the home, a row of dots). Also the outside
# links the footer shows as icons: `links` is the single source for them.
class Navigation < Bridgetown::Component
  Link = Data.define(:icon, :title, :href, :external)

  SITE_LINKS = { "Tags" => "/tags", "About" => "/about" }.freeze

  def initialize(metadata:, tagline: false)
    @metadata = metadata
    @tagline = tagline
  end

  def site_links = SITE_LINKS

  # The name split around its ampersand, which the masthead sets in italic.
  def name_parts = @metadata.title.split(" & ", 2)

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
