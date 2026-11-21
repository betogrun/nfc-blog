# `bin/bt new_post "Post title"` creates src/_posts/YYYY-MM-DD-<slug>.md as a draft.
# Registered with the CLI in config/custom_commands.rb.
module Commands
  class NewPost < Bridgetown::Command
    class PostExists < StandardError; end

    POSTS_DIR = "src/_posts".freeze

    self.description = "Create a draft post in #{POSTS_DIR}"

    one :title, "The post title (quote it)", required: true

    # The slug becomes the permanent URL (/posts/<slug>): lowercase ASCII letters, digits
    # and single hyphens. It is a starting point; rename the file before publishing for a
    # shorter slug. Apostrophes are dropped so "what's" reads "whats", not "what-s".
    def self.slug(title)
      Bridgetown::Utils.slugify(title.delete("'’"), mode: "latin")
    end

    def call
      path = File.join(POSTS_DIR, "#{Date.today.iso8601}-#{self.class.slug(title)}.md")
      File.open(path, File::WRONLY | File::CREAT | File::EXCL) { it.write(front_matter) }
      Bridgetown.logger.info "New post:", path
      path
    rescue Errno::EEXIST
      raise PostExists, "#{path} already exists"
    end

    private

    # Same fields and quoting as the existing posts; the date comes from the file name.
    # A JSON string is a valid double-quoted YAML scalar, so any title is escaped safely.
    def front_matter
      <<~YAML
        ---
        layout: post
        title: #{title.to_json}
        description: ""
        tags: []
        published: false
        ---

      YAML
    end
  end
end
