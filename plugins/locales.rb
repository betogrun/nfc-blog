# The site's languages: English at the root, Portuguese under /pt/ with the same paths.
# Templates render with I18n.locale set to the page's language, so these default to it.
module Locales
  DEFAULT = :en

  # The path in a language: "/tags" is "/pt/tags" in Portuguese.
  def self.path(path, locale = I18n.locale)
    locale.to_sym == DEFAULT ? path : "/#{locale}#{path}"
  end

  # The posts in a language, newest first.
  def self.posts(locale = I18n.locale)
    Bridgetown::Current.site.collections.posts.resources.select { it.data.locale == locale.to_sym }
  end

  # The posts a list shows in a language: every post, as its translation where one exists.
  # Translations only exist for English posts, so the English list holds them all.
  def self.listed_posts(locale = I18n.locale)
    posts(DEFAULT).map { translation(it, locale) || it }
  end

  # A post's version in a language, if there is one.
  def self.translation(post, locale = I18n.locale)
    post.all_locales.find { it.data.locale == locale.to_sym }
  end

  # The versions of a page, as { locale => path }, when it exists in more than one
  # language. Translations share the path after the language prefix. A page with
  # `translations: false` has none, even if the other language has the same path.
  def self.alternates(page)
    return {} if page.data["translations"] == false

    path = unprefixed(page.respond_to?(:relative_url) ? page.relative_url : page.url)
    versions = I18n.available_locales.to_h { [it, path(path, it)] }.select { |_, url| urls.include?(url) }
    versions.size > 1 ? versions : {}
  end

  def self.unprefixed(path)
    others = I18n.available_locales - [DEFAULT]
    path.sub(%r{\A/(#{others.join("|")})(?=/)}, "")
  end

  # Every page's path in this build.
  def self.urls
    site = Bridgetown::Current.site
    site.tmp_cache[:locale_urls] ||= Set.new(
      site.collections.each_value.flat_map(&:resources).map(&:relative_url) + site.generated_pages.map(&:url)
    )
  end

  # A site metadata value in a language: Portuguese values sit under `pt:` in
  # src/_data/site_metadata.yml, and the English one is the fallback.
  def self.metadata(metadata, key, locale = I18n.locale)
    metadata.dig(locale.to_s, key.to_s) || metadata[key.to_s]
  end
end
