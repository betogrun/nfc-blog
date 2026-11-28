# The mono meta line of a post: ISO date, reading time and its tags. The post page
# leaves out the tags (they go to "filed under"), and lists the date (it ends the
# meta line on the right, see ArticleListItem).
class ArticleMeta < Bridgetown::Component
  WORDS_PER_MINUTE = 250

  Tag = Data.define(:slug, :name) do
    def href = Locales.path("/tag/#{slug}/")
  end

  def self.tags(post) = Array(post.data.tags).map { Tag.new(it, tag_name(it)) }

  # A tag's display name: src/_data/tags.yml, or its translation in src/_locales.
  def self.tag_name(slug)
    I18n.t("tag_names.#{slug}", default: Bridgetown::Current.site.data.tags[slug]&.name || slug)
  end

  def self.date(post) = post.date.strftime("%Y-%m-%d")

  def initialize(post:, date: true, tags: true)
    @post = post
    @show_date = date
    @show_tags = tags
  end

  def date = self.class.date(@post)

  # Same formula as the Chalk theme, so reading times don't change.
  def minutes = (@post.content.split.size + WORDS_PER_MINUTE) / WORDS_PER_MINUTE

  def tags = @show_tags ? self.class.tags(@post) : []
end
