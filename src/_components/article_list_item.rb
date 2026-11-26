# A post in the home and tag lists, set like a book's contents: the title, a dotted
# leader and the date on one line, then the description and the meta line.
class ArticleListItem < Bridgetown::Component
  def initialize(post:)
    @post = post
  end

  def date = ArticleMeta.date(@post)
end
