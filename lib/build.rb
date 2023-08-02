require 'tilt/erb'
require 'cgi'
require_relative 'helpers'

class Build
  def initialize(output_dir, parser)
    @output_dir = output_dir
    @parser = parser
  end

  def clean
    output_dir.rmtree
    output_dir.mkpath
  end

  def generate_site
    template = Tilt::ERBTemplate.new('templates/page.html.erb')
    helpers = Helpers.new
    sections = parser.index.children.filter {|d| ['Howto', 'Concepts', 'Technologies'].include?(d.title) }

    parser.pages.each do |page|
      navigation = if page.slug == "" || page.slug == "index"
        sections
      elsif page.is_index?
        [page]
      else
        [page.parent]
      end

      title = page.title == "" ? "Knowledge base" : page.title

      output = template.render(
        helpers,
        title: CGI.escape_html(title),
        meta_description: CGI.escape_html(title),
        content: page.content&.generate_html,
        top_level_nav: sections,
        navigation: navigation,
      )

      file_path = output_dir + page.slug

      # Map every page to a directory with an index, regardless of whether
      # it has any children. This enables child pages to be added in the
      # future without changing the parent URL.
      # I.e. rather than foo/bar.html evolving into foo/bar and foo/bar/*
      # we have foo/bar evolving into foo/bar and foo/bar/*
      html_path = if page.is_index?
        file_path + "index.html"
      else
        file_path.dirname + file_path.basename + "index.html"
      end

      html_path.dirname.mkpath

      File.open(html_path, 'w') do |f|
        f.write(output)
      end
    end
  end

  def generate_example
    template = Tilt::ERBTemplate.new('templates/page.html.erb')

    output = template.render(
      Helpers.new,
      title: CGI.escape_html("Stuff & things"),
      meta_description: CGI.escape_html("In which we define \"stuff\" and \"things\""),
      content: "<p>Hello world</p>",
      top_level_nav: parser.index.children.filter {|d| ['Howto', 'Concepts', 'Technologies'].include?(d.title) },
      navigation: parser.index.children.filter {|d| ['Howto', 'Concepts', 'Technologies'].include?(d.title) },
    )

    file_path = output_dir + 'page.html'
    File.open(file_path, 'w') do |f|
      f.write(output)
    end
  end

  def copy_assets
    assets_dir = Pathname.new('assets')
    assets_dir.glob('*') do |asset|
      FileUtils.cp(asset, output_dir)
    end
  end

  attr_reader :output_dir
  attr_reader :parser
end
