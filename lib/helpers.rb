require 'tilt/erb'

class Helpers
  def initialize
    @nav_template = Tilt::ERBTemplate.new("templates/nav_section.html.erb")
    @index_template = Tilt::ERBTemplate.new("templates/generated_index.html.erb")
    @breadcrumb_template = Tilt::ERBTemplate.new("templates/breadcrumb.html.erb")
  end

  def render_nav(navigation_root)
    @nav_template.render(self, page: navigation_root)
  end

  def render_index(children)
    @index_template.render(self, children: children)
  end

  def render_breadcrumbs(page)
    anscestors = []
    current = page
    while !current.parent.nil?
      anscestors << current.parent
      current = current.parent
    end

    @breadcrumb_template.render(self, page: page, breadcrumbs: anscestors.reverse)
  end

  def escape(str)
    CGI.escape_html(str)
  end

  def header_tag(level)
    raise ValueError unless (1..).include?(level)

    if level > 5
      level = 5
    end

    content = (yield)

    "<h#{level}>#{content}</h#{level}>"
  end

  def link_page(page)
    href = "/#{page.value.slug}/"

    if page.parent.nil?
      link_tag("/", "Home")
    else
      link_tag(href, page.value.title)
    end
  end

  def link_tag(href, link_text)
    "<a href=\"#{href}\">#{link_text}</a>"
  end

  def ordinalise(number)
    ordinal = case number % 10
      when 1
        number == 11 ? 'th' : 'st'
      when 2
        number == 12 ? 'th' : 'nd'
      when 3
        number == 13 ? 'th' : 'rd'
      else
        'th'
      end
    "#{number}#{ordinal}"
  end

  def humanise_time(time)
    day_with_ordinal = ordinalise(time.day)
    time.strftime("#{day_with_ordinal} %B, %-Y")
  end
end
