# A post in the home and tag lists, after Chalk: the title on its own line, the
# description, then the meta line with the date at its right end, and a light rule.
class ArticleListItem < Bridgetown::Component
  def initialize(post:)
    @post = post
  end

  def date = ArticleMeta.date(@post)

  def datetime = ArticleMeta.datetime(@post)

  # A post not yet translated, listed in its own language on the other language's pages.
  def other_language? = @post.data.locale != I18n.locale
end
