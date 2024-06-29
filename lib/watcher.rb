require 'filewatcher'
require 'filewatcher/spinner'
require 'pathname'

class Watcher
  def self.watch(path, builder)
    watch = Watcher.new(path, builder)
    yield
    watch.finalize
  end

  def initialize(vault_path, builder)
    # TODO: add a watch on assets
    puts "Watching for changes..."
    @asset_path = Pathname.new(__dir__).parent + "assets"
    @filewatcher = Filewatcher.new([vault_path.to_s, @asset_path], spinner: true)
    @builder = builder
    @vault_path = vault_path
    @thread = Thread.new(@filewatcher) do |fw|
      fw.watch do |changes|
        changes.each do |filename, event|
          # TODO: handle different kinds of event
          puts "#{filename} #{event}"
          rebuild(filename)
        end
      end
    end
  end

  def rebuild(filename)
     if filename.to_s.start_with?(vault_path.to_s)
      filename = Pathname.new(filename).relative_path_from(vault_path)
      puts filename.basename

      ## TODO this is broken for index files - rewrite
      if filename.extname == "md"
        slug = filename.to_s.sub(/.md$/, "")
        builder.build_and_write_page_by_slug(slug)
      else
        builder.copy_media_page_by_slug(filename)
      end

    elsif filename.to_s.start_with?(asset_path.to_s)
      builder.copy_asset(filename)
    end
  end

  def finalize
    filewatcher.stop
    thread.join
  end

  private

  attr_reader :vault_path
  attr_reader :asset_path
  attr_reader :builder
  attr_reader :thread
  attr_reader :filewatcher
end
