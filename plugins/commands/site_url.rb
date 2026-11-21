module Commands
  module SiteUrl
    private

    # The site URL is set in config/initializers.rb, which the CLI doesn't run for commands.
    def site_url
      Bridgetown.configuration.tap { it.run_initializers!(context: :static) }.url
    end
  end
end
