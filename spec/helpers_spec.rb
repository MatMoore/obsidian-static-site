# frozen_string_literal: true

require_relative '../lib/helpers'
require 'obsidian/parser'
require_relative './spec_helper'

describe(Helpers) do
  subject(:helpers) { Helpers.new }

  describe "#render_nav" do
    it "renders 2 levels" do
      navigation = Obsidian::Page.create_root
      navigation.add_page("foo/bar")
      navigation.add_page("a/b/c")

      result = helpers.render_nav(navigation.children, max_level: 2)
      document = Oga.parse_html(result)

      expect(document).to contain_css('h1:root > a[href="/foo/"]')
      expect(document).to contain_css('h1:root > a[href="/a/"]')
      expect(document).to contain_css('ul.navigation-list:root > li > a[href="/a/b/"]')
      expect(document).to contain_css('ul.navigation-list:root > li > a[href="/foo/bar/"]')
      expect(document).not_to contain_css('a[href="/a/b/c"]')
    end

    it "does not render an empty navigation" do
      result = helpers.render_nav([])
      expect(result).to eq("")
    end
  end

  describe "#render_index" do
    let(:result) { helpers.render_index(children) }
    let(:document) { Oga.parse_html(result) }
    let(:children) do
      index = Obsidian::Page.create_root
      index.add_page("foo/bar")
      index.add_page("a/b/c")
      index.add_page("d")
      index.add_page("e")

      index.children
    end

    it "includes child directories" do
      expect(document).to contain_css('.index > h3 > a[href="/foo/"]')
      expect(document).to contain_css('.index > h3 > a[href="/a/"]')
    end

    it "includes grandchildren" do
      expect(document).to contain_css('.index > ul > li > a[href="/a/b/"]')
    end

    it "includes child pages" do
      expect(document).to contain_css('.index > ul > li > a[href="/d/"]')
      expect(document).to contain_css('.index > ul > li > a[href="/e/"]')
    end

    it "excludes grand-grandchildren" do
      expect(document).not_to contain_css('.index > ul > li > a[href="/a/b/c/"]')
    end
  end

  describe '#render_breadcrumbs' do
    it 'renders all parts of the breadcrumb trail' do
      index = Obsidian::Page.create_root
      baz = index.add_page("foo/bar/baz")

      result = helpers.render_breadcrumbs(baz)
      document = Oga.parse_html(result)

      items = document.css('li')

      expect(items.map(&:text)).to eq(["Home", "foo", "bar", "baz"])

      # first value is a bug
      expect(items.map { |li| li.at_xpath("a")&.get("href") }).to eq(["//", "/foo/", "/foo/bar/", nil])
    end
  end

  describe "#header_tag" do
    it "generates header html" do
      result = helpers.header_tag(1) do
        "inner content"
      end

      expect(result).to eq("<h1>inner content</h1>")
    end
  end
end
