require "minitest/autorun"
require "pandocomatic"

describe Pandocomatic do
  before do
    @pandocomatic = Pandocomatic::Pandocomatic.new
  end

  describe "when asked for version" do
    it "must respond with" do
      @pandocomatic.version.must_equal [0, 1, 0]
    end
  end
end
