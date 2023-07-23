require 'tilt/erb'
require 'cgi'
require_relative 'navigation'
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
    filtered_nav = parser.index.directories.filter {|d| ['Howto', 'Concepts', 'Technologies'].include?(d.title) }

    parser.notes.each do |note|
      output = template.render(
        helpers,
        title: CGI.escape_html(note.title),
        meta_description: CGI.escape_html(note.title),
        content: "<p>Hello #{note.title}</p>",
        top_level_nav: filtered_nav,
        navigation: filtered_nav,
      )

      file_path = output_dir + note.slug

      # This URL structure maps directly to the vault structure.
      # However, we could also consider putting each note into its own directory
      # This would give us simple, extensionless URLs, and converting a note into a directory
      # of notes won't break URLs.
      html_path = if note.is_a?(Obsidian::Index)
        file_path + "index.html"
      else
        file_path.dirname + "#{file_path.basename}.html"
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
      top_level_nav: parser.index.directories.filter {|d| ['Howto', 'Concepts', 'Technologies'].include?(d.title) },
      navigation: parser.index.directories.filter {|d| ['Howto', 'Concepts', 'Technologies'].include?(d.title) },
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
