require 'minitest/autorun'
require 'pandocomatic'

class TestPandocomatic < Minitest::Test

  def setup
  end

  def cli(options_in)
    Pandocomatic::CLI.parse options_in
  end

  def test_version
    assert_includes cli('-v'), :version
    assert_includes cli('--version'), :version
    assert_includes cli('-q --version'), :version
    assert_includes cli('--version test/files/readable_test_file'), :version
  end

  def test_help
    assert_includes cli('-h'), :help
    assert_includes cli('-h -q'), :help
    assert_includes cli('-i test/files/readable_test_file -h'), :help
    assert_includes cli('--help'), :help
  end

  def test_version_and_help
    assert_includes cli('-v -h'), :version
    assert_includes cli('-v -h'), :help
    assert_includes cli('-v -h'), :help
  end

  def test_input
    e = assert_raises Pandocomatic::CLIError do
      cli('')
      cli('-i')
      cli('-q')
      cli('-q -i')
    end
    assert_equal e.type, Pandocomatic::CLIError::NO_INPUT_GIVEN

    assert_includes cli('test/files/readable_test_file'), :input
    assert_includes cli('-i test/files/readable_test_file'), :input
    assert_includes cli('--input test/files/readable_test_file'), :input

    e = assert_raises Pandocomatic::CLIError do
      cli('test/files/non_existing_file')
      cli('-i test/files/non_existing_file')
      cli('--input test/files/non_existing_file')
    end
    assert_equal e.type, Pandocomatic::CLIError::INPUT_DOES_NOT_EXIST

    e = assert_raises Pandocomatic::CLIError do
      cli('test/files/unreadable_test_file')
      cli('-i test/files/unreadable_test_file')
      cli('--input test/files/unreadable_test_file')
    end
    assert_equal e.type, Pandocomatic::CLIError::INPUT_IS_NOT_READABLE
  end

  def test_output
  end

  def test_input_matches_output
  end

  def test_data_dir
  end

  def test_config
  end

  def test_skip
  end

  def test_other_options
  end

  def test_problematic_invocation
    e = assert_raises Pandocomatic::CLIError do
      cli('--some-unknown-option')
    end
    assert_equal e.type, Pandocomatic::CLIError::PROBLEMATIC_INVOCATION
  end

  def test_too_many_options
    e = assert_raises Pandocomatic::CLIError do
      cli('-i files/test/readable_test_file files/test/another_file')
    end
    assert_equal e.type, Pandocomatic::CLIError::TOO_MANY_OPTIONS
  end

end
