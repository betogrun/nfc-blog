# The topics (post tags) of the posts listed in the page's language, in alphabetical
# order of their names, each with its post count and a link to its page. It closes every
# home page under a heading, and makes up the Topics page without one.
class TopicIndex < Bridgetown::Component
  Topic = Data.define(:tag, :count)

  def self.topics(locale = I18n.locale)
    counts = Locales.listed_posts(locale).flat_map { ArticleMeta.tags(it) }.tally
    counts.map { |tag, count| Topic.new(tag, count) }.sort_by { it.tag.name.unicode_normalize(:nfd).downcase }
  end

  def initialize(heading: true, topics: self.class.topics)
    @heading = heading
    @topics = topics
  end
end
