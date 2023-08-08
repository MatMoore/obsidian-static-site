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

  def build(page)
    navigation = if page.slug == "" || page.slug == "index"
      [index.find_in_tree("Concepts")].compact
    elsif page.is_index?
      [page]
    else
      [page.parent]
    end

    if page.title == ""
      title = "Knowledge base"
    elsif page.is_index?
      title = "Index: #{page.title}"
    else
      title = page.title
    end

    output = template.render(
      helpers,
      title: CGI.escape_html(title),
      meta_description: CGI.escape_html(title),
      content: page.content&.generate_html,
      top_level_nav: top_level_nav,
      navigation: navigation,
      page_section: get_section(page) || index.find_in_tree("Concepts"),
      children: page.children,
      page: page
    )
  end

  private

  attr_reader :template
  attr_reader :index
  attr_reader :helpers
  attr_reader :top_level_nav

  def get_section(page)
    return nil if page.nil?

    if top_level_nav.include?(page)
      page
    else
      get_section(page.parent)
    end
  end
end
