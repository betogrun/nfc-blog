require "net/http"
require "nokolexbor"
require_relative "site_url"

# `bin/bt check_deploy URL` checks a deployed copy of the site (a Cloudflare preview or
# production): every legacy URL, sitemap URL and feed link answers 200 without redirecting,
# unknown paths get the 404 page with status 404, and no page was rewritten by Cloudflare.
# On the site's own domain, each legacy URL over plain HTTP must redirect permanently to HTTPS.
# Registered with the CLI in config/custom_commands.rb.
module Commands
  class CheckDeploy < Bridgetown::Command
    include SiteUrl

    LEGACY_URLS = File.expand_path("../../test/fixtures/legacy_urls.txt", __dir__)
    FEEDS = %w[/sitemap.xml /feed.xml /robots.txt].freeze
    MISSING_PAGE = "/check-deploy-missing-page".freeze
    NOT_FOUND_MARKER = 'class="notfound-wrapper"'.freeze # from src/404.erb
    PERMANENT_REDIRECTS = [301, 308].freeze

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

      responses.flat_map { |path, response| page_problems(path, response) } +
        not_found_problems(host.get(MISSING_PAGE))
    end

    # Paths of the site's own URLs in the sitemap and the feed's entries.
    def self.linked_paths(responses, site_url)
      origin = site_url.chomp("/")
      urls = xml_values(responses["/sitemap.xml"], "loc") +
             xml_values(responses["/feed.xml"], "entry link[rel='alternate']")

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

    # Requests each path over HTTP; it must redirect permanently to the same path under `origin`.
    def self.https_problems(http_host, origin:, paths:)
      paths.filter_map do |path|
        response = http_host.get(path)
        target = "#{origin}#{path}"
        next if PERMANENT_REDIRECTS.include?(response.status) && response.location == target

        redirect = " to #{response.location}" if response.location
        "#{path} over HTTP: status #{response.status}#{redirect}, expected a permanent redirect to #{target}"
      end
    end

    def self.own_domain?(url, site_url:) = URI(url).host == URI(site_url).host

    def self.not_found_problems(response)
      if response.status != 404
        ["#{MISSING_PAGE}: status #{response.status}, expected 404"]
      elsif !response.body.include?(NOT_FOUND_MARKER)
        ["#{MISSING_PAGE}: status 404 without the site's 404 page"]
      else
        []
      end
    end

    def call
      problems = self.class.problems(Client.new(url), site_url:) + https_problems
      if problems.empty?
        puts "check_deploy: #{url} serves every page"
      else
        puts problems
        puts "\ncheck_deploy: #{problems.size} problem(s) on #{url}"
        exit false
      end
    end

    private

    # Previews on workers.dev serve plain HTTP, so only the site's own domain is checked.
    def https_problems
      return [] unless self.class.own_domain?(url, site_url:)

      http_host = Client.new(url.sub(/\Ahttps:/, "http:"))
      self.class.https_problems(http_host, origin: url.chomp("/"), paths: self.class.legacy_paths)
    end
  end
end
