# Generates /tag/:slug/ for every tag in src/_data/tags.yml, including tags with no
# posts yet. Jekyll did the same with the _my_tags collection, so those URLs exist.
class Builders::TagPages < SiteBuilder
  def build
    generator do
      site.data.tags.each do |slug, tag|
        add_resource :pages, "tag/#{slug}.html" do
          layout :tag
          title tag.name
          tag_slug slug
          permalink "/tag/#{slug}/"
        end
      end
    end
  end
end
