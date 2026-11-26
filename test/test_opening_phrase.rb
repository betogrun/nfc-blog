require "minitest_helper"
require_relative "../plugins/opening_phrase"

class TestOpeningPhrase < Minitest::Test
  describe "opening phrase" do
    def wrap(html) = OpeningPhrase.wrap(html)

    it "wraps the words up to the first punctuation mark" do
      assert_equal %(<p><span class="opening">For most of my career,</span> a pull request was a record.</p>),
                   wrap("<p>For most of my career, a pull request was a record.</p>")
    end

    it "stops after five words when there is no punctuation" do
      assert_equal %(<p><span class="opening">Sometimes we realize that a</span> problematic file was added</p>),
                   wrap("<p>Sometimes we realize that a problematic file was added</p>")
    end

    it "ignores punctuation inside a word" do
      assert_equal %(<p><span class="opening">Since Rails 5.1 it is</span> possible</p>),
                   wrap("<p>Since Rails 5.1 it is possible</p>")
    end

    it "uses the first paragraph, after any heading" do
      assert_equal %(<h3>Intro</h3>\n<p><span class="opening">By default,</span> no.</p>\n<p>Later, yes.</p>),
                   wrap("<h3>Intro</h3>\n<p>By default, no.</p>\n<p>Later, yes.</p>")
    end

    it "stops at inline markup" do
      assert_equal %(<p><span class="opening">This post shows</span> <a href="/x">a link</a>, then more.</p>),
                   wrap(%(<p>This post shows <a href="/x">a link</a>, then more.</p>))
    end

    it "leaves alone a paragraph that opens with markup, and content without paragraphs" do
      [%(<p><a href="https://asdf-vm.com">ASDF</a> is a version manager.</p>),
       %(<div class="highlight"><pre>code, here</pre></div>)].each { assert_equal it, wrap(it) }
    end
  end
end
