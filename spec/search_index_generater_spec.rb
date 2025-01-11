require_relative '../lib/search_index_generator'

RSpec.describe(SearchIndexGenerator) do
  let(:page) { Obsidian::Page.new(slug: '/foo', title: "Foo") }
  let(:parsed_page) { Obsidian::ParsedPage.new(html: '<p>abc</p>') }

  subject { described_class.new }

  it 'does a thing' do
    subject.add_doc(page, parsed_page)
    expect(subject.generate).to eq({
      "version" => "2.3.9",
      "fields" => ["title","slug","html"],
      "fieldVectors" => [["title/undefined",[0,0.182]],["slug/undefined",[0,0.182]],["html/undefined",[1,0.288]]],"invertedIndex" => [["foo",{"_index" => 0,"title" => {"undefined" => {}},"slug" => {"undefined" => {}},"html" => {}}],["p>abc</p",{"_index" => 1,"title" => {},"slug" => {},"html" => {"undefined" => {}}}]],"pipeline" => ["stemmer"]
    })
  end
end
