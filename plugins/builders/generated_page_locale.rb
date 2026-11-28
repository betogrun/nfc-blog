# Bridgetown sets the locale while it renders resources, but not generated pages, which
# include the paginated homes. Set it from the page's data, so /pt/ renders in Portuguese.
class Builders::GeneratedPageLocale < SiteBuilder
  def build
    hook :generated_pages, :pre_render do |page|
      site.locale = page.data["locale"] || page.original_resource&.data&.locale || Locales::DEFAULT
    end

    hook :generated_pages, :post_render do
      site.locale = Locales::DEFAULT
    end
  end
end
