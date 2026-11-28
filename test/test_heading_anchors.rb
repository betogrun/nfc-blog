require "minitest_helper"
require_relative "../plugins/heading_anchors"

class TestHeadingAnchors < Minitest::Test
  describe "heading anchors" do
    def add(html, label: "Link to this section") = HeadingAnchors.add(html, label:)

    def anchor(id, label = "Link to this section")
      %(<a class="heading-anchor" href="##{id}" aria-label="#{label}"><span aria-hidden="true">#</span></a>)
    end

    it "appends a link to the heading's own id inside the heading" do
      assert_equal %(<h3 id="the-hook">The hook #{anchor("the-hook")}</h3>), add(%(<h3 id="the-hook">The hook</h3>))
    end

    it "links h2, h3 and h4" do
      [2, 3, 4].each { assert_equal %(<h#{it} id="a">A #{anchor("a")}</h#{it}>), add(%(<h#{it} id="a">A</h#{it}>)) }
    end

    it "leaves alone other heading levels and headings without an id" do
      [%(<h1 id="a">A</h1>), %(<h5 id="b">B</h5>), %(<h6 id="sources">Sources:</h6>), %(<h3>No id</h3>)]
        .each { assert_equal it, add(it) }
    end

    it "keeps inline markup and other attributes of the heading" do
      assert_equal %(<h3 class="x" id="the-pagy-object">The <code>pagy</code> object #{anchor("the-pagy-object")}</h3>),
                   add(%(<h3 class="x" id="the-pagy-object">The <code>pagy</code> object</h3>))
    end

    it "escapes the label" do
      assert_includes add(%(<h3 id="a">A</h3>), label: %(Say "hi" & go)), %(aria-label="Say &quot;hi&quot; &amp; go")
    end

    it "leaves the rest of the content untouched" do
      html = %(<p><code>&lt;h3 id="x"&gt;</code></p>\n<pre>## not a heading</pre>)

      assert_equal html, add(html)
    end
  end
end
