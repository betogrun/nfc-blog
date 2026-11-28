require "net/http"
require "nokolexbor"
require_relative "site_url"

# `bin/bt check_deploy URL` checks a deployed copy of the site (a Cloudflare preview or
# production): every legacy URL, sitemap URL (translations included) and feed link answers 200
# without redirecting, unknown paths get their language's 404 page with status 404, and no
# page was rewritten by Cloudflare.
# Registered with the CLI in config/custom_commands.rb.
module Commands
  class CheckDeploy < Bridgetown::Command
    include SiteUrl

    LEGACY_URLS = File.expand_path("../../test/fixtures/legacy_urls.txt", __dir__)
    FEEDS = %w[/sitemap.xml /feed.xml /pt/feed.xml /robots.txt].freeze
    # A missing path in each language, and the <html lang> its 404 page must have.
    MISSING_PAGES = {
      "/check-deploy-missing-page" => 'lang="en"',
      "/pt/check-deploy-missing-page" => 'lang="pt-BR"'
    }.freeze
    NOT_FOUND_MARKER = 'class="notfound-wrapper"'.freeze # from src/404.erb

    Response = Data.define(:status, :body, :location) do
      def initialize(status:, body:, location: nil) = super
    end

    # Requests paths from the deployed site over one connection, without following redirects.
    class Client
      def initialize(base_url)
        @base = URI(base_url.chomp("/"))
      end

      def get(path)
        request = Net::HTTP::Get.new("#{@base.path}#{path}", "user-agent" => "check_deploy")
        response = connection.request(request)
        Response.new(status: response.code.to_i, body: response.body.to_s, location: response["location"])
      end

      private

      def connection
        @connection ||= Net::HTTP.start(@base.host, @base.port, use_ssl: @base.scheme == "https",
                                                                open_timeout: 10, read_timeout: 30)
      end
    end

    self.description = "Check a deployed copy of the site (legacy URLs, sitemap, feed, 404)"

    one :url, "Base URL of the deploy, e.g. a preview URL", required: true

    def self.legacy_paths
      File.readlines(LEGACY_URLS, chomp: true).reject { it.empty? || it.start_with?("#") }
    end

    # Each path is requested once; the order of the report follows the order of the requests.
    def self.problems(host, site_url:, legacy_paths: self.legacy_paths)
      responses = Hash.new { |cache, path| cache[path] = host.get(path) }
      (legacy_paths + FEEDS).each { responses[it] }
      linked_paths(responses, site_url).each { responses[it] }

      responses.flat_map { |path, response| page_problems(path, response) } + missing_page_problems(host)
    end

    def self.missing_page_problems(host)
      MISSING_PAGES.flat_map { |path, lang| not_found_problems(path, host.get(path), lang) }
    end

    # Paths of the site's own URLs in the sitemap (with each page's translations) and the
    # feeds' entries.
    def self.linked_paths(responses, site_url)
      origin = site_url.chomp("/")
      urls = xml_values(responses["/sitemap.xml"], "loc, xhtml\\:link") +
             %w[/feed.xml /pt/feed.xml].flat_map { xml_values(responses[it], "entry link[rel='alternate']") }

      urls.filter_map { it.delete_prefix(origin) if it.start_with?("#{origin}/") }
    end

    def self.xml_values(response, selector)
      return [] unless response.status == 200

      Nokolexbor::Document.parse(response.body).css(selector).map { it[:href] || it.text }
    end

    def self.page_problems(path, response)
      if response.status != 200
        redirect = " to #{response.location}" if response.location
        ["#{path}: status #{response.status}#{redirect}, expected 200"]
      elsif response.body.include?("/cdn-cgi/")
        ["#{path}: rewritten by Cloudflare (references /cdn-cgi/)"]
      else
        []
      end
    end

    def self.not_found_problems(path, response, lang)
      if response.status != 404
        ["#{path}: status #{response.status}, expected 404"]
      elsif !(response.body.include?(NOT_FOUND_MARKER) && response.body.include?(lang))
        ["#{path}: status 404 without the site's 404 page"]
      else
        []
      end
    end

    def call
      problems = self.class.problems(Client.new(url), site_url:)
      if problems.empty?
        puts "check_deploy: #{url} serves every page"
      else
        puts problems
        puts "\ncheck_deploy: #{problems.size} problem(s) on #{url}"
        exit false
      end
    end
  end
end
