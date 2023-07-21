require 'tilt/erb'
require 'cgi'
require_relative 'navigation'
require_relative 'helpers'

class Build
  def initialize(output_dir, parser)
    @output_dir = output_dir
    @parser = parser
  end

  def mkpath
    output_dir.mkpath
  end

  def generate_example
    template = Tilt::ERBTemplate.new('templates/page.html.erb')

    output = template.render(
      Helpers.new,
      title: CGI.escape_html("Stuff & things"),
      meta_description: CGI.escape_html("In which we define \"stuff\" and \"things\""),
      content: "<p>Hello world</p>",
      navigation: parser.index.directories.filter {|d| ['Concepts', 'Technologies'].include?(d.title) },
    )

    file_path = output_dir + 'page.html'
    File.open(file_path, 'w') do |f|
      f.write(output)
    end
  end

  def map_index(index)
    Navigation::Section.new(
      title: index.title,
      entries:
        #index.directories.map { |d| map_index(d) } +
        index.notes.map { |e| Navigation::Entry.new(e.slug, e.title) }
    )
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
