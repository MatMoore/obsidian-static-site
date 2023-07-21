require 'erb'
require 'cgi'
require_relative 'navigation'

class Build
  def initialize(output_dir)
    @output_dir = output_dir
  end

  def mkpath
    output_dir.mkpath
  end

  def generate_example
    template = File.read("templates/page.html.erb")

    output = ERB.new(template).result_with_hash(
      title: CGI.escape_html("Stuff & things"),
      meta_description: CGI.escape_html("In which we define \"stuff\" and \"things\""),
      content: "<p>Hello world</p>",
      navigation: generate_example_nav
    )

    file_path = output_dir + 'page.html'
    File.open(file_path, 'w') do |f|
      f.write(output)
    end
  end

  def generate_example_nav
    [
      Navigation::Section.new(
        title: 'Stuff',
        entries: [
          Navigation::Entry.new('', 'Cat')
        ]
      ),
      Navigation::Section.new(
        title: 'Things',
        entries: [
          Navigation::Entry.new('', 'Apple'),
          Navigation::Entry.new('', 'Banana'),
        ]
      )
    ]
  end

  def copy_assets
    assets_dir = Pathname.new('assets')
    assets_dir.glob('*') do |asset|
      FileUtils.cp(asset, output_dir)
    end
  end

  attr_reader :output_dir
end
