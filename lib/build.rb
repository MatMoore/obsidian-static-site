require_relative "page_builder"

class Build
  SECTIONS = ['Howto', 'Concepts', 'Technologies']

  def initialize(output_dir, parser)
    @output_dir = output_dir
    @parser = parser
    @page_builder = PageBuilder.new(
      index: parser.index,
      top_level_nav: top_level_nav
    )
  end

  def clean
    output_dir.rmtree
    output_dir.mkpath
  end

  def generate_site
    pages_to_generate = [parser.index] + top_level_nav
    pages_to_generate.each do |p|
      p.walk_tree do |page|
        output = page_builder.build(page)

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
  end

  def copy_assets
    FileUtils.cp_r('assets', output_dir + 'assets')
  end

  attr_reader :output_dir
  attr_reader :parser
  attr_reader :page_builder

  private

  def top_level_nav
     parser.index.children.filter {|d| ['Howto', 'Concepts', 'Technologies'].include?(d.title) }
  end
end
