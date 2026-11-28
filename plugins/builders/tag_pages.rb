# Generates /tag/:slug/ for every tag in src/_data/tags.yml, including tags with no
# posts yet. Jekyll did the same with the _my_tags collection, so those URLs exist.
# Each language gets its own copy: /pt/tag/:slug/ lists the Portuguese posts.
class Builders::TagPages < SiteBuilder
  def build
    generator do
      site.config.available_locales.each do |locale|
        site.data.tags.each { |slug, tag| add_tag_page(slug, tag, locale) }
      end
    end
  end

  private

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
