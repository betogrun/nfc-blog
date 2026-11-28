# The header: a line with the reader's preferences (language and theme), then the
# centered masthead (the name, the byline linking to About, the rolled tagline on the
# home, a row of dots). Also the outside links the footer shows as icons: `links` is
# the single source for them.
class Navigation < Bridgetown::Component
  Link = Data.define(:icon, :title, :href, :external)

  # alternates: the page's versions, { locale => path } (Locales.alternates); the language
  # selector shows only when there is more than one. page: the page being rendered, so
  # the links to About can mark it as current there.
  def initialize(metadata:, tagline: false, alternates: {}, page: nil)
    @metadata = metadata
    @tagline = tagline
    @alternates = alternates
    @page = page
  end

  def home = Locales.path("/")

  def author = @metadata.author

  def about_path = Locales.path("/about")

  def about_page? = !@page.nil? && Locales.unprefixed(Locales.url(@page)) == "/about"

  def taglines = Locales.metadata(@metadata, :taglines)

  # The name split around its ampersand, which the masthead sets in italic.
  def name_parts = @metadata.title.split(" & ", 2)

  def links
    social = @metadata.social

    [
      Link.new("github", "GitHub", "https://github.com/#{social.github}", true),
      Link.new("linkedin", "LinkedIn", "https://www.linkedin.com/in/#{social.linkedin}", true),
      Link.new("x", "X", "https://x.com/#{social.x}", true),
      Link.new("email", I18n.t("footer.email"), "mailto:#{@metadata.email}", false),
      Link.new("rss", I18n.t("footer.rss"), Locales.path("/feed.xml"), true)
    ]
  end
end
