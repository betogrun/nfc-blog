# A post in the home and tag lists, after Chalk: the title on its own line, the
# description, then the meta line with the date at its right end, and a light rule.
class ArticleListItem < Bridgetown::Component
  def initialize(post:)
    @post = post
  end

  def date = ArticleMeta.date(@post)
end
