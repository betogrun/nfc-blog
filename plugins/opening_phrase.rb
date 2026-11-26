# Marks a post's opening phrase for small caps, as a book sets the start of a chapter.
#
# Posts are plain Markdown, so nothing marks the phrase: it is the first paragraph's
# opening words, up to the first punctuation mark that ends a word and at most
# MAX_WORDS, stopping at any inline markup (a link, code). A paragraph that opens with
# markup gets no phrase.
module OpeningPhrase
  MAX_WORDS = 5
  FIRST_PARAGRAPH = /<p>(?<text>[^<]*)/
  ENDS_PHRASE = /[,.:;?!]\z/

  def self.wrap(html)
    match = html.match(FIRST_PARAGRAPH)
    return html unless match

    phrase = phrase_in(match[:text])
    return html if phrase.empty?

    start = match.begin(:text)
    html[0...start] + %(<span class="opening">#{phrase}</span>) + html[(start + phrase.length)..]
  end

  def self.phrase_in(text)
    finish = 0
    text.to_enum(:scan, /\S+(?=\s|\z)/).each_with_index do |_, index|
      word = Regexp.last_match
      finish = word.end(0)
      break if index + 1 == MAX_WORDS || word[0].match?(ENDS_PHRASE)
    end
    text[0, finish]
  end
end
