require 'tilt/erb'

class Helpers
  def initialize
    @nav_template = Tilt::ERBTemplate.new("templates/nav_section.html.erb")
  end

  def render_nav(navigation, level: 1, max_level: 3)
    @nav_template.render(self, navigation: navigation, level: level, max_level: max_level)
  end

  def header_tag(level)
    raise ValueError unless (1..).include?(level)

    if level > 5
      level = 5
    end

    content = (yield)

    "<h#{level}>#{content}</h#{level}>"
  end

  def link_note(note)
    if note.is_a?(Obsidian::Index)
      href = "/#{note.slug}/"
    else
      href = "/#{note.slug}.html"
    end

    link_tag(href, note.title)
  end

  def link_tag(href, link_text)
    "<a href=\"#{href}\">#{link_text}</a>"
  end
end
