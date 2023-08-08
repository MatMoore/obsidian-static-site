# frozen_string_literal: true

require_relative "spec_helper"
require_relative "../lib/page_builder"
require "obsidian/parser"

describe PageBuilder do
  let(:root_page) { Obsidian::Page.create_root }

  subject(:page_builder) {
    described_class.new(
      index: root_page,
      top_level_nav: root_page.children
    )
  }

  subject(:result) do
    page_builder.build(root_page)
  end

  let(:document) { Oga.parse_html(result) }

  describe "#build" do
    it "contains a skip link" do
      expect(document).to contain_css('a.skip-link[href="#content"]')
    end

    context "when the page is an index with no content" do
      before do
        root_page.add_page("foo")
      end

      it "contains a generated index" do
        expect(document.at_css("#content").text).to include("foo")
      end
    end

    context "when the page is an index with content" do
      let(:page) { Obsidian::Page.new(title: "", slug: "", content: content) }
      let(:content) { double(:content, generate_html: "hello world")}

      subject(:result) do
        described_class.new(
          index: page,
          top_level_nav: page.children
        ).build(page)
      end

      before do
        page.add_page("foo")
      end

      it "contains the index content" do
        expect(document.at_css("#content").text).to include("hello world")
      end
    end
  end

  describe "#get_title" do
    it "defaults to 'Knowledge base'" do
      title = page_builder.get_title(root_page)
      expect(title).to eq("Knowledge base")
    end

    it "prepends the 'Index:' prefix" do
      page1 = root_page.add_page("foo")
      page2 = page1.add_page("bar")

      title = page_builder.get_title(page1)
      expect(title).to eq("Index: foo")
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

      expect(navigation).to eq(concepts)
    end

    it "uses the page for an index page" do
      page = root_page.add_page("foo")
      page.add_page("bar")

      navigation = page_builder.get_navigation_root(page)

      expect(navigation).to eq(page)
    end

    it "uses the parent for a non-index page" do
      page1 = root_page.add_page("foo")
      page2 = page1.add_page("bar")

      navigation = page_builder.get_navigation_root(page2)

      expect(navigation).to eq(page1)
    end

    describe "#get_section" do
      it "returns the top level navigation section" do
        section = root_page.add_page("foo")
        page = section.add_page("bar/baz")

        page_section = page_builder.get_section(page)

        expect(page_section).to eq(section)
      end
    end
  end
end
