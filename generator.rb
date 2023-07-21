#!/usr/bin/env ruby
require 'pathname'
require 'webrick'
require_relative 'lib/build'
require_relative 'lib/server'

output_dir = Pathname.new('output')
build = Build.new(output_dir)

build.mkpath
build.generate_example
build.copy_assets

# TODO: watch files and regenerate/refresh on change
Server.serve(output_dir)
