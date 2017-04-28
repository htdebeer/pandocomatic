require 'minitest/autorun'
require 'pandocomatic'

class TestPandocomaticCLI < Minitest::Test

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
    assert_equal e.message, "No input given"

    assert_includes cli('test/files/readable_test_file'), :input
    assert_includes cli('-i test/files/readable_test_file'), :input
    assert_includes cli('--input test/files/readable_test_file'), :input

    e = assert_raises Pandocomatic::CLIError do
      cli('test/files/non_existing_file')
      cli('-i test/files/non_existing_file')
      cli('--input test/files/non_existing_file')
    end
    assert_equal e.message, "Input does not exist"

    # TODO: I cannot add "unreadable" files to git. I am not so sure mocking the
    # file system is such a good idea. Creating file and making it unreadable
    # in the test also seems a bit fishy.
    # e = assert_raises Pandocomatic::CLIError do
    #   cli('test/files/unreadable_test_file')
    #   cli('-i test/files/unreadable_test_file')
    #   cli('--input test/files/unreadable_test_file')
    # end
    # assert_equal e.message, Pandocomatic::CLIError::INPUT_IS_NOT_READABLE
  end

  def test_output
    e = assert_raises Pandocomatic::CLIError do
      cli('-i test/files/readable_test_dir')
    end
    assert_equal e.message, "No output given"
    
    e = assert_raises Pandocomatic::CLIError do
      cli('-i test/files/readable_test_file -o test/files/readable_test_dir')
    end
    assert_equal e.message, "Output is not a file"
    
    e = assert_raises Pandocomatic::CLIError do
      cli('-i test/files/readable_test_dir -o test/files/readable_test_file')
    end
    assert_equal e.message, "Output is not a directory"
    
    assert_includes cli('--input test/files/readable_test_file'), :output
    assert_includes cli('--input test/files/readable_test_file -o test/files/readable_test_file'), :output
    assert_includes cli('--input test/files/readable_test_dir -o test'), :output
  end

  def test_data_dir
    e = assert_raises Pandocomatic::CLIError do
      cli('-i test/files/readable_test_file -d test/files/non_existing_file')
    end
    assert_equal e.message, "Data dir does not exist"
    
    e = assert_raises Pandocomatic::CLIError do
      cli('-i test/files/readable_test_file -d test/files/readable_test_file')
    end
    assert_equal e.message, "Data dir is not a directory"
    
    # I am unable to commit and push an unreadable directory to git; so this
    # test is switched off for now.
    #
    # e = assert_raises Pandocomatic::CLIError do
    #   cli('-i test/files/readable_test_file -d test/files/unreadable_test_dir')
    # end
    # assert_equal e.message, "Data dir is not readable"

    assert_includes cli('-i test/files/readable_test_file -d test/files/readable_test_dir'), :data_dir
  end

  def test_config
    e = assert_raises Pandocomatic::CLIError do
      cli('-i test/files/readable_test_file -c test/files/non_existing_file')
    end
    assert_equal e.message, "Config file does not exist"
    
    e = assert_raises Pandocomatic::CLIError do
      cli('-i test/files/readable_test_file -c test/files/readable_test_dir')
    end
    assert_equal e.message, "Config file is not a file"
    
    assert_includes cli('-i test/files/readable_test_file -c test/files/readable_test_file'), :config
  end

  def test_other_options
    assert_includes cli('-i test/files/readable_test_file -y'), :dry_run
    assert_includes cli('-i test/files/readable_test_file -q'), :quiet
    assert_includes cli('-i test/files/readable_test_file -m'), :modified_only
  end

  def test_problematic_invocation
    e = assert_raises Pandocomatic::CLIError do
      cli('--some-unknown-option')
      cli('-Z')
    end
    assert_equal e.message, "Problematic invocation"
  end

  def test_too_many_options
    e = assert_raises Pandocomatic::CLIError do
      cli('-i files/test/readable_test_file files/test/another_file')
    end
    assert_equal e.message, "Too many options"
  end

end
