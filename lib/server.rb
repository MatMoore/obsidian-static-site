require 'webrick'

module Server
  def self.serve(output_dir)
    server = WEBrick::HTTPServer.new(DocumentRoot: output_dir)

    t = Thread.new { server.start }
    trap("INT") { server.shutdown }

    url = "http://localhost:#{server.config[:Port]}/"
    launch_browser(url)

    t.join
  end

  def self.launch_browser(path)
    system 'open', path
  end
end
