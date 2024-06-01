require 'tilt/erb'

class Helpers
  def initialize
    @nav_template = Tilt::ERBTemplate.new("templates/nav_section.html.erb")
    @index_template = Tilt::ERBTemplate.new("templates/generated_index.html.erb")
    @breadcrumb_template = Tilt::ERBTemplate.new("templates/breadcrumb.html.erb")
  end

  def render_nav(navigation_root, level: 1, max_level: 3)
    @nav_template.render(self, page: navigation_root, level: level, max_level: max_level)
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
    href = "/#{page.slug}/"

    if page.parent.nil?
      link_tag("/", "Home")
    else
      link_tag(href, page.title)
    end
  end

  def link_tag(href, link_text)
    "<a href=\"#{href}\">#{link_text}</a>"
  end

  def humanise_time(time)
    seconds_elapsed = time - Time.now
    days_elapsed = (seconds_elapsed / (60 * 60 * 24))
    if days_elapsed > 365
      years_elapsed = (days_elapsed / 365)
      "about #{years_elapsed.round} months ago"
    elsif days_elapsed > 30
      months_elapsed = (days_elapsed / 30)
      "about #{months_elapsed.round} months ago"
    elsif days_elapsed > 2
      "#{days_elapsed.round} days ago"
    elsif days_elapsed > 1
      "yesterday"
    else
      "today"
    end
  end
end
