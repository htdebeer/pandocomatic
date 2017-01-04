require 'minitest/autorun'
require 'pandocomatic/pandocomatic'

class TestPandocomatic < Minitest::Test
  def setup
    @pandocomatic = Pandocomatic::Pandocomatic.new
  end

  def test_pandocomatic
    true
  end

  def test_pandocomatic_version
    assert_equal Pandocomatic::VERSION, @pandocomatic.version
  end
end
