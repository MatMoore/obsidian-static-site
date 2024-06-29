require_relative '../lib/build'
require 'obsidian/parser'
require_relative './spec_helper'

RSpec.describe(Build) do
  let(:index) { Obsidian::Vault.create_root }
  let(:parser) { instance_double('Obsidian::Parser', :parser, index: index, media_index: nil) }
  let(:mockfile) { instance_double('File', :mockfile) }
  let(:parsed_page) { Obsidian::ParsedPage.new(html: '<p>abc</p>') }
  let(:page) { instance_double('Obsidian::Page', :page, parse: parsed_page, title: 'ABC', last_modified: nil, slug: 'foo/bar/baz') }
  let(:tree_node) { Obsidian::Tree.new(page) }
  subject(:build) { Build.new(Pathname.new('output_dir'), parser) }

  before do
    index.add_page('foo/bar/baz')
    allow_any_instance_of(Pathname).to receive(:mkpath)
    allow(index).to receive('find_in_tree').and_return(tree_node)
  end

  describe '#build_and_write_page_by_slug' do
    it "writes to a file with name matching the slug" do
      expected_path = Pathname.new('output_dir/foo/bar/baz/index.html')
      expect(File).to receive(:open).with(expected_path, "w").and_yield(mockfile)

      expect(mockfile).to receive(:write) do |content|
        expect(content).to include('<p>abc</p>')
      end

      build.build_and_write_page_by_slug("foo/bar/baz")
    end
  end
end
