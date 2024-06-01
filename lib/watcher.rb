require 'filewatcher'
require 'filewatcher/spinner'
require 'pathname'

class Watcher
  def self.watch(path, builder)
    watch = Watcher.new(path, builder)
    yield
    watch.finalize
  end

  def initialize(path, builder)
    # TODO: add a watch on assets
    puts "Watching for changes..."
    @filewatcher = Filewatcher.new([path.to_s + "/**/*.md"], spinner: true)
    @builder = builder
    @vault_path = path
    @thread = Thread.new(@filewatcher) do |fw|
      fw.watch do |changes|
        changes.each do |filename, event|
          puts "#{filename} #{event}"
          rebuild(filename)
        end
      end
    end
  end

  def rebuild(filename)
    filename = Pathname.new(filename).relative_path_from(vault_path)
    slug = filename.to_s.sub(/.md$/, "")
    builder.build_and_write_page_by_slug(slug)
  end

  def finalize
    filewatcher.stop
    thread.join
  end

  private

  attr_reader :vault_path
  attr_reader :builder
  attr_reader :thread
  attr_reader :filewatcher
end
