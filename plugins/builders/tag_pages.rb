# Generates /tag/:slug/ for every tag in src/_data/tags.yml, including tags with no
# posts yet. Jekyll did the same with the _my_tags collection, so those URLs exist.
# Other languages get a copy only for tags with posts: /pt/tag/:slug/ has no legacy URL to
# keep, and an empty translation would only be a dead end.
class Builders::TagPages < SiteBuilder
  def build
    generator do
      site.config.available_locales.each do |locale|
        site.data.tags.each do |slug, tag|
          add_tag_page(slug, tag, locale) if locale == Locales::DEFAULT || used?(slug)
        end
      end
    end
  end

  private

  def used?(slug) = Locales.posts(Locales::DEFAULT).any? { it.data.tags&.include?(slug) }

  def add_tag_page(slug, tag, locale)
    name = I18n.t("tag_names.#{slug}", locale:, default: tag.name)
    path = Locales.path("/tag/#{slug}/", locale)

    add_resource :pages, "#{path.delete_prefix("/").chomp("/")}.html" do
      layout :tag
      title name
      tag_slug slug
      locale locale
      permalink path
    end
  end
end
