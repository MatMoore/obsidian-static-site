require 'filewatcher'
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

  def build_and_write_page_by_slug(slug)
    page = parser.index.find_in_tree(slug)
    if page.nil?
      raise "Page not found #{slug}"
    end
    build_and_write_page(page)
  end

  def copy_media_page_by_slug(slug)
    page = parser.media_index.find_in_tree(slug)
    if page.nil?
      raise "Page not found #{slug}"
    end
    copy_media_page(page)
  end

  def build_and_write_page(page)
    output = page_builder.build(page, page.value.parse(root: parser.index, media_root: parser.media_index))

    file_path = output_dir + page.value.slug

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

  def generate_site
    top_level_nav.each do |page|
      page.mark_referenced
    end

    parser.index.walk_tree do |page|
      parsed_page = page.parse
      next if parsed_page.nil?

      page.mark_referenced if parsed_page.frontmatter["public"]
    end

    # Remove pages without "public" in the frontmatter
    parser.index.prune!

    copy_media_pages

    # Generate all the pages
    parser.index.walk_tree do |page|
      build_and_write_page(page)
    end
  end

  def copy_media_pages
    parser.media.each do |a|
      copy_media_page(a)
    end
  end

  def copy_media_page(page)
    file_path = output_dir + page.value.slug
    file_path.parent.mkpath

    FileUtils.copy(page.source_path, file_path)
  end

  def copy_assets
    FileUtils.cp_r('assets', output_dir + 'assets')
  end

  def copy_asset(filename)
    asset_path = Pathname.new('assets').expand_path
    from = Pathname.new(filename).relative_path_from(asset_path)
    FileUtils.copy(filename, output_dir + 'assets' + from)
  end

  attr_reader :output_dir
  attr_reader :parser
  attr_reader :page_builder

  private

  def top_level_nav
    parser.index.tree.children
  end
end
