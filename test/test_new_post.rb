require "minitest_helper"
require "tmpdir"
require_relative "../config/custom_commands"

class TestNewPost < Minitest::Test
  def setup
    @root = Dir.mktmpdir
    FileUtils.mkdir_p File.join(@root, "src/_posts")
  end

  def teardown
    FileUtils.rm_rf @root
  end

  # The command returns a path relative to the project root; expand it inside the
  # temp dir so assertions never touch the real src/_posts.
  def new_post(*)
    Dir.chdir(@root) { File.expand_path(Commands::NewPost[*].call) }
  end

  def front_matter(path)
    YAML.safe_load(File.read(path)[/\A---\n(.*?)\n---\n/m, 1])
  end

  def test_is_registered_as_new_post
    command = Bridgetown::Commands::Application.parse(["new_post", "Hello World"]).command

    assert_instance_of Commands::NewPost, command
    assert_equal "Hello World", command.title
  end

  def test_creates_a_dated_post_named_after_the_title
    new_post "Hello World"

    assert_path_exists File.join(@root, "src/_posts/#{Date.today.iso8601}-hello-world.md")
  end

  def test_starts_as_a_draft_with_the_front_matter_posts_use
    path = new_post("Hello World")

    assert_equal(
      { "layout" => "post", "title" => "Hello World", "description" => "", "tags" => [], "published" => false },
      front_matter(path)
    )
  end

  def test_keeps_titles_with_yaml_syntax_intact
    title = %(asdf: "No version set" for #bundle)

    assert_equal title, front_matter(new_post(title))["title"]
  end

  def test_refuses_to_overwrite_an_existing_post
    path = new_post("Hello World")
    File.write(path, "my draft")

    assert_raises(Commands::NewPost::PostExists) { new_post "Hello World" }
    assert_equal "my draft", File.read(path)
  end

  def test_slugs_are_url_safe
    slug = Commands::NewPost.slug("Ruby 4.0: what's new in Pattern Matching?")

    assert_match(/\A[a-z0-9]+(-[a-z0-9]+)*\z/, slug)
  end

  def test_slugs_drop_apostrophes_and_accents
    assert_equal "configuracao-do-rails-whats-new", Commands::NewPost.slug("Configuração do Rails: what’s new")
  end
end
