#!/usr/bin/env ruby
require 'pathname'
require 'webrick'
require 'benchmark'
require 'obsidian/parser'
require_relative 'lib/build'
require_relative 'lib/server'
require_relative 'lib/watcher'

output_dir = Pathname.new('output')
parser = Obsidian::Parser.new(Pathname.new('/Users/mat/Dropbox/tech-notes'))
build = Build.new(output_dir, parser)

puts "Generating..."

build.clean

Benchmark.bm(20) do |x|
  x.report("Generate pages") { build.generate_site }
  x.report("Copy assets") { build.copy_assets }
end

Watcher.watch('/Users/mat/Dropbox/tech-notes', build) do
  Server.serve(output_dir)
end
