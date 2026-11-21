# Date, reading time and tags shown under a post title (home, tag pages, post page).
class ArticleMeta < Bridgetown::Component
  WORDS_PER_MINUTE = 250

  def initialize(post:)
    @post = post
  end

  def date = @post.date.strftime("%B %-d, %Y")

  # Same formula as the Chalk theme, so reading times don't change.
  def minutes = (@post.content.split.size + WORDS_PER_MINUTE) / WORDS_PER_MINUTE

  def tags
    names = Bridgetown::Current.site.data.tags
    Array(@post.data.tags).map { [it, names[it]&.name || it] }
  end
end
