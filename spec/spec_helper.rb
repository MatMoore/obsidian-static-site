require "oga"

RSpec::Matchers.define :contain_css do |xpath|
  match do |document|
    !document.at_css(xpath).nil?
  end
end
