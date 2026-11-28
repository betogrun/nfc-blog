# Wraps bridgetown-seo-tag's `seo` helper for the <head>.
#
# The plugin marks a page as an article whenever it has a date, and every Bridgetown
# resource has one (it falls back to the build time). Only posts are articles: other
# pages get og:type "website" and no published time. Pagination pages
# (/posts/page/:num/) are not resources, so they have no collection.
class Builders::SeoMetadata < SiteBuilder
  ARTICLE_TAGS = %r{
    <meta\ property="og:type"\ content="article"\ />\s*
    <meta\ property="article:published_time"\ content="[^"]*"\ />
  }x
  WEBSITE_TAG = '<meta property="og:type" content="website" />'.freeze
  OG_LOCALE = %r{<meta property="og:locale" content="[^"]*" />}

  def build
    helper "seo_metadata" do
      page = helpers.view.page
      html = helpers.seo(title: false).to_s
      post = page.respond_to?(:collection) && page.collection.label == "posts"
      html = html.sub(ARTICLE_TAGS, WEBSITE_TAG) unless post

      localize(html, page).html_safe
    end
  end

  private

  # seo-tag knows one site language and description. Give a page its own og:locale, the
  # other versions' as alternates, and the site description in the page's language.
  def localize(html, page)
    alternates = Locales.alternates(page).keys - [I18n.locale]
    tags = [I18n.locale, *alternates].each_with_index.map do |locale, index|
      property = index.zero? ? "og:locale" : "og:locale:alternate"
      %(<meta property="#{property}" content="#{I18n.t("og_locale", locale:)}" />)
    end

    html.sub(OG_LOCALE, tags.join("\n")).gsub(escaped_description, escaped_description(I18n.locale))
  end

  def escaped_description(locale = Locales::DEFAULT)
    ERB::Util.html_escape(Locales.metadata(site.metadata, :description, locale))
  end
end
