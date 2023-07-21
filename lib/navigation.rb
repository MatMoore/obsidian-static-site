module Navigation
  Section = Data.define(:title, :entries, :directories, :level)
  Entry = Data.define(:href, :link_text)
end
