# Inlines an icon from frontend/icons so CSS can color it with `fill`.
# The files are Chalk's <symbol> sprites; only the viewBox and shapes are kept.
class Icon < Bridgetown::Component
  SYMBOL = %r{<symbol[^>]*viewBox="(?<view_box>[^"]+)"[^>]*>\s*(?:<title>.*?</title>)?(?<shapes>.*?)</symbol>}m

  def initialize(name)
    @name = name
  end

  def template
    symbol = File.read(File.join(Bridgetown::Current.site.root_dir, "frontend/icons/#{@name}.svg")).match(SYMBOL)

    <<~HTML.strip.html_safe
      <svg xmlns="http://www.w3.org/2000/svg" class="icon-#{@name}" viewBox="#{symbol[:view_box]}" aria-hidden="true">#{symbol[:shapes].strip}</svg>
    HTML
  end
end
