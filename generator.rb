#!/usr/bin/env ruby
require 'pathname'
require 'webrick'
require 'obsidian/parser'
require_relative 'lib/build'
require_relative 'lib/server'

output_dir = Pathname.new('output')
parser = Obsidian::Parser.new(Pathname.new('/Users/mat/tech-notes'))
build = Build.new(output_dir, parser)

build.mkpath
build.generate_example
build.copy_assets

# TODO: watch files and regenerate/refresh on change
Server.serve(output_dir)
