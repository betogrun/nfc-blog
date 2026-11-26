# Jekyll paginated the home 4 posts a page, so /posts/page/2/ to /4/ are legacy URLs
# (test/fixtures/legacy_urls.txt). At the home's current page size fewer pages may
# exist: each number past the last real page gets a page that forwards to the last
# one. It answers 200, so the legacy URL and deploy checks pass, and it stays out of
# search (noindex, canonical to the real page) and out of the sitemap.
class Builders::LegacyPagination < SiteBuilder
  LAST_LEGACY_PAGE = 4

  def build
    generator do
      last = last_page
      ((last + 1)..LAST_LEGACY_PAGE).each { add_forward(it, last) }
    end
  end

  private

  def last_page = [(site.collections.posts.resources.size / per_page.to_f).ceil, 1].max

  # The home's page size, from its front matter (src/index.erb).
  def per_page = site.collections.pages.resources.filter_map { it.data.paginate&.per_page }.first

  def add_forward(number, last)
    add_resource :pages, "posts/page/#{number}.html" do
      layout :forward
      title "Page #{number}"
      forward_to last == 1 ? "/" : "/posts/page/#{last}/"
      permalink "/posts/page/#{number}/"
      sitemap false
    end
  end
end
