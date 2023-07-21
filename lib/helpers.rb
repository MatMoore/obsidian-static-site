require 'tilt/erb'

class Helpers
  def initialize
    @nav_template = Tilt::ERBTemplate.new("templates/nav_section.html.erb")
  end

  def render_nav(navigation, level: 1)
    #@nav_template = Tilt::ERBTemplate.new("templates/nav_section.html.erb")
    puts "!!! render nav #{navigation.map(&:title)}"
    @nav_template.render(self, navigation: navigation, level: level)
  end

  def header_tag(level)
    raise ValueError unless (1..).include?(level)

    if level > 5
      level = 5
    end

    content = (yield)

    "<h#{level}>#{content}</h#{level}>"
  end

  def link_tag(href, link_text)
    "<a href=\"#{href}\">#{link_text}</a>"
  end
end
