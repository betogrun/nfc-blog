require "erb"

# Links a post's section headings to themselves, so a reader can point someone at one
# step. Kramdown already gives every heading an id; this appends, inside h2 to h4, a link
# to that id: a `#` hidden from screen readers, which hear the label instead. The ids
# stay Kramdown's, since shared links depend on them. h5 and h6 (the "Sources" labels)
# and headings without an id get no link.
module HeadingAnchors
  HEADING = %r{<h(?<level>[2-4])(?<attributes>\s[^>]*)>(?<content>.*?)</h\k<level>>}m
  ID = /\bid="(?<id>[^"]+)"/

  def self.add(html, label:)
    label = ERB::Util.html_escape(label)

    html.gsub(HEADING) do
      heading = Regexp.last_match
      id = heading[:attributes][ID, :id]
      next heading[0] unless id

      link = %(<a class="heading-anchor" href="##{id}" aria-label="#{label}"><span aria-hidden="true">#</span></a>)
      %(<h#{heading[:level]}#{heading[:attributes]}>#{heading[:content]} #{link}</h#{heading[:level]}>)
    end
  end
end
