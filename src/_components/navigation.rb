# Site header: logo plus icon links (about, social, email, feed) and the theme toggle.
class Navigation < Bridgetown::Component
  Link = Data.define(:icon, :title, :href, :external)

  def initialize(metadata:)
    @metadata = metadata
  end

  def links
    social = @metadata.social

    [
      Link.new("about", "About me", "/about", false),
      Link.new("twitter", "Twitter", "https://twitter.com/#{social.twitter}", true),
      Link.new("github", "GitHub", "https://github.com/#{social.github}", true),
      Link.new("linkedin", "LinkedIn", "https://www.linkedin.com/in/#{social.linkedin}", true),
      Link.new("email", "Email", "mailto:#{@metadata.email}", false),
      Link.new("rss", "RSS", "/feed.xml", true)
    ]
  end
end
