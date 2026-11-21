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

  def build
    helper "seo_metadata" do
      page = helpers.view.page
      html = helpers.seo(title: false).to_s
      post = page.respond_to?(:collection) && page.collection.label == "posts"

      (post ? html : html.sub(ARTICLE_TAGS, WEBSITE_TAG)).html_safe
    end
  end
end
