# frozen_string_literal: true

require_relative "spec_helper"
require_relative "../lib/page_builder"
require "obsidian/parser"

describe PageBuilder do
  let(:root_page) { Obsidian::Vault.create_root }
  let(:parsed_page) { Obsidian::ParsedPage.new(html: 'foo') }
  let(:page) { instance_double('Obsidian::Page', :page, parse: parsed_page, title: 'ABC', last_modified: nil, slug: 'foo/bar/baz') }
  let(:tree_node) { Obsidian::Tree.new(page) }

  subject(:page_builder) {
    described_class.new(
      index: root_page,
      top_level_nav: root_page.tree.children
    )
  }

  subject(:result) do
    page_builder.build(tree_node, parsed_page)
  end

  let(:document) { Oga.parse_html(result) }

  describe "#build" do
    it "contains a skip link" do
      expect(document).to contain_css('a.skip-link[href="#content"]')
    end

    context "when the page is an index with no content" do
      before do
        tree_node.add_child("dummy", :dummy)
      end

      it "contains a generated index" do
        expect(document.at_css("#content").text).to include("foo")
      end
    end

    context "when the page is an index with content" do
      before do
        tree_node.add_child("dummy", :dummy)
      end

      it "contains the index content" do
        expect(document.at_css("#content").text).to include("ABC")
      end
    end
  end

  describe "#get_title" do
    it "defaults to 'Knowledge base'" do
      title = page_builder.get_title(root_page)
      expect(title).to eq("Knowledge base")
    end

    it "uses the page title for regular pages" do
      page = root_page.add_page("foo")

      title = page_builder.get_title(page)

      expect(title).to eq("foo")
    end
  end

  describe "#get_navigation_root" do
    it "uses concepts navigation for the root" do
      concepts = root_page.add_page("Concepts")

      navigation = page_builder.get_navigation_root(root_page)

      expect(navigation).to eq(concepts.tree)
    end

    it "uses the page for an index page" do
      page = root_page.add_page("foo")
      page.add_page("bar")

      navigation = page_builder.get_navigation_root(page.tree)

      expect(navigation).to eq(page.tree)
    end

    it "uses the parent for a non-index page" do
      page1 = root_page.add_page("foo")
      page2 = page1.add_page("bar")

      navigation = page_builder.get_navigation_root(page2.tree)

      expect(navigation).to eq(page1.tree)
    end

    describe "#get_section" do
      it "returns the top level navigation section" do
        section = root_page.add_page("foo")
        page = section.add_page("bar/baz")

        page_section = page_builder.get_section(page.tree)

        expect(page_section).to eq(section.tree)
      end
    end
  end
end
