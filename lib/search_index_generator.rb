require 'obsidian/parser'
require 'mini_racer'

class SearchIndexGenerator
  def initialize
    @docs = []
  end

  def generate
      context = MiniRacer::Context.new
      context.load(File.expand_path('../../assets/lunr.js', __FILE__))

      js = %(
        var idx = lunr(function () {
          this.field('title');
          this.field('slug');
          this.field('html');
          var docs = #{docs.to_json};
          docs.forEach(function(doc) {
            this.add(doc);
          }, this);
        });
      )
      puts js
      context.eval(js);

      puts context.eval("JSON.stringify(idx)") # Inspect the JavaScript object

      data = context.eval("idx.toJSON()")
      data
  end

  def add_doc(page, parsed_page)
    return if page.slug.nil? || page.title.nil?

    docs << {
      "title": page.title,
      "slug": page.slug,
      "html": parsed_page&.html || ""
    }
  end

  private

  attr_reader :docs
end
