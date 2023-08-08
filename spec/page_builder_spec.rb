# frozen_string_literal: true

require_relative "spec_helper"
require_relative "../lib/page_builder"
require "obsidian/parser"

describe PageBuilder do
  let(:empty_page) { Obsidian::Page.create_root }

  subject(:result) do
    described_class.new(
      index: empty_page,
      top_level_nav: empty_page.children
    ).build(empty_page)
  end

  let(:document) { Oga.parse_html(result) }

  describe "#build" do
    it "contains a skip link" do
      expect(document).to contain_css('a.skip-link[href="#content"]')
    end

    context "when the page is an index with no content" do
      before do
        empty_page.add_page("foo")
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
end
