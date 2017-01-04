require 'minitest/autorun'
require 'pandocomatic/pandocomatic'

describe Pandocomatic do
  before do
    @pandocomatic = Pandocomatic::Pandocomatic.new
  end

  describe 'when asked for version' do
    it 'must respond with' do
      @pandocomatic.version.must_equal Pandocomatic::VERSION
    end
  end
end
