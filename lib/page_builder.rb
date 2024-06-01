require 'tilt/erb'
require 'cgi'
require_relative 'helpers'

class PageBuilder
  def initialize(index:, top_level_nav:)
    @index = index
    @top_level_nav = top_level_nav
    @template = Tilt::ERBTemplate.new('templates/page.html.erb')
    @helpers = Helpers.new
  end

  def build(page, parsed_page)
    output = template.render(
      helpers,
      title: CGI.escape_html(get_title(page)),
      meta_description: CGI.escape_html(get_title(page)),
      content: parsed_page&.to_html,
      top_level_nav: top_level_nav,
      navigation_root: get_navigation_root(page),
      page_section: get_section(page) || index.find_in_tree("Concepts"),
      children: page.children,
      page: page
    )
  end

  def get_title(page)
    if page.title == ""
      "Knowledge base"
    elsif page.is_index?
      "#{page.title} - index"
    else
      page.title
    end
  end

  def get_navigation_root(page)
    if page.parent.nil?
      index.find_in_tree("Concepts")
    elsif page.is_index?
      page
    else
      page.parent
    end
  end

  def get_section(page)
    return nil if page.nil?

    if top_level_nav.include?(page)
      page
    else
      get_section(page.parent)
    end
  end

  private

  attr_reader :template
  attr_reader :index
  attr_reader :helpers
  attr_reader :top_level_nav
end
