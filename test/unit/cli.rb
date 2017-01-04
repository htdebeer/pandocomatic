require 'minitest/autorun'
require 'pandocomatic/cli'

class TestPandocomatic < Minitest::Test
  def setup
  end

  def opts2opts(options_in, options_out)
    assert_equal Pandocomatic::CLI.parse(options_in), options_out
  end

  def test_cli_help_general
    opts2opts ["help"], [{:topic => :default}, nil, nil]
  end

end
