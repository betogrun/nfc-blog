# `bin/bt check_links` runs html-proofer over the build in output/: internal links, anchors,
# images, scripts, favicon and Open Graph URLs must resolve. `--external` also requests every
# external link, which needs the network, so CI leaves it out.
# Registered with the CLI in config/custom_commands.rb.
require_relative "site_url"

module Commands
  class CheckLinks < Bridgetown::Command
    include SiteUrl

    Problem = Data.define(:path, :line, :description, :status) do
      def key = [path, description]
      def to_s = "#{[path, line].compact.join(":")}: #{description}#{" (status #{status})" if status}"
    end

    # Problems in post content, left as they are on the live site because posts aren't
    # edited without the author's approval. Remove an entry once its post is fixed (the
    # check fails while a listed problem is gone).
    KNOWN_FAILURES = {
      "posts/docker-rails-vue.html" => ["http://localhost:5000 is not an HTTPS link"],
      "posts/git-pre-push-hook.html" => [
        "http://gmodarelli.com/2015/01/code_reviews_rubocop_pre_commit/ is not an HTTPS link"
      ],
      "posts/git-repo-via-cmd.html" => [
        "http://stackoverflow.com/questions/2423777/is-it-possible-to-create-a-remote-repo-on-github-from-the-cli-" \
        "without-opening-br/10325316#10325316 is not an HTTPS link"
      ]
    }.freeze

    CHECKS = %w[Links Images Scripts Favicon OpenGraph].freeze

    self.description = "Check links and images in the built site"

    options do
      option "--external", "Also check external links (needs the network)"
    end

    one :directory, "The built site", default: "output"

    # Problems found in the build, minus the known ones; a known problem that no longer
    # shows up is reported too. Known entries for pages the build lacks are skipped.
    def self.failures(directory, site_url:, external: false, known: KNOWN_FAILURES)
      root = File.expand_path(directory)
      expected = known.select { |path, _| File.exist?(File.join(root, path)) }
                      .flat_map { |path, descriptions| descriptions.map { [path, it] } }
      problems = proof(root, site_url:, external:)

      problems.reject { expected.include?(it.key) } + (expected - problems.map(&:key)).map { stale(*it) }
    end

    # html-proofer loads libcurl, so it is required here rather than with every CLI command.
    def self.proof(root, site_url:, external:)
      require "html-proofer"
      Warning[:experimental] = false # html-proofer reads files with IO::Buffer

      runner = HTMLProofer.check_directory(root, proofer_options(site_url:, external:))
      # html-proofer prints its report and exits on failures; keep them instead, so known
      # problems can be dropped before reporting.
      def runner.report_failed_checks = nil
      runner.run

      runner.reporter.failures.flat_map(&:last).map do |failure|
        Problem.new(path: failure.path.delete_prefix(File.join(root, "")), line: failure.line,
                    description: failure.description, status: failure.status)
      end
    end

    # Absolute URLs on the site's own domain (canonical, og:url, the share link) are mapped
    # back to paths, so they are checked against the build instead of the live site.
    def self.proofer_options(site_url:, external:)
      {
        checks: CHECKS,
        disable_external: !external,
        swap_urls: { %r{\A#{Regexp.escape(site_url.chomp("/"))}(?:/|\z)} => "/" },
        log_level: :error
      }
    end

    def self.stale(path, description)
      Problem.new(path:, line: nil, status: nil,
                  description: "no longer fails, remove it from KNOWN_FAILURES: #{description}")
    end

    def call
      problems = self.class.failures(directory, site_url:, external: options[:external])
      if problems.empty?
        puts "check_links: no broken links in #{directory}"
      else
        puts problems
        puts "\ncheck_links: #{problems.size} problem(s) in #{directory}"
        exit false
      end
    end
  end
end
