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

    # TODO: I cannot add "unreadable" files to git. I am not so sure mocking the
    # file system is such a good idea. Creating file and making it unreadable
    # in the test also seems a bit fishy.
    # e = assert_raises Pandocomatic::CLIError do
    #   cli('test/files/unreadable_test_file')
    #   cli('-i test/files/unreadable_test_file')
    #   cli('--input test/files/unreadable_test_file')
    # end
    # assert_equal e.type, Pandocomatic::CLIError::INPUT_IS_NOT_READABLE
  end

  def test_output
    e = assert_raises Pandocomatic::CLIError do
      cli('-i test/files/readable_test_dir')
    end
    assert_equal e.type, Pandocomatic::CLIError::NO_OUTPUT_GIVEN
    
    e = assert_raises Pandocomatic::CLIError do
      cli('-i test/files/readable_test_file -o test/files/readable_test_dir')
    end
    assert_equal e.type, Pandocomatic::CLIError::OUTPUT_IS_NOT_A_FILE
    
    e = assert_raises Pandocomatic::CLIError do
      cli('-i test/files/readable_test_dir -o test/files/readable_test_file')
    end
    assert_equal e.type, Pandocomatic::CLIError::OUTPUT_IS_NOT_A_DIRECTORY
    
    assert_includes cli('--input test/files/readable_test_file'), :output
    assert_includes cli('--input test/files/readable_test_file -o test/files/readable_test_file'), :output
    assert_includes cli('--input test/files/readable_test_dir -o test'), :output
  end

  def test_data_dir
    e = assert_raises Pandocomatic::CLIError do
      cli('-i test/files/readable_test_file -d test/files/non_existing_file')
    end
    assert_equal e.type, Pandocomatic::CLIError::DATA_DIR_DOES_NOT_EXIST
    
    e = assert_raises Pandocomatic::CLIError do
      cli('-i test/files/readable_test_file -d test/files/readable_test_file')
    end
    assert_equal e.type, Pandocomatic::CLIError::DATA_DIR_IS_NOT_A_DIRECTORY
    
    e = assert_raises Pandocomatic::CLIError do
      cli('-i test/files/readable_test_file -d test/files/unreadable_test_dir')
    end
    assert_equal e.type, Pandocomatic::CLIError::DATA_DIR_IS_NOT_READABLE

    assert_includes cli('-i test/files/readable_test_file -d test/files/readable_test_dir'), :data_dir
  end

  def test_config
    e = assert_raises Pandocomatic::CLIError do
      cli('-i test/files/readable_test_file -c test/files/non_existing_file')
    end
    assert_equal e.type, Pandocomatic::CLIError::CONFIG_FILE_DOES_NOT_EXIST
    
    e = assert_raises Pandocomatic::CLIError do
      cli('-i test/files/readable_test_file -c test/files/readable_test_dir')
    end
    assert_equal e.type, Pandocomatic::CLIError::CONFIG_FILE_IS_NOT_A_FILE
    
    assert_includes cli('-i test/files/readable_test_file -c test/files/readable_test_file'), :config
  end

  def test_skip
    assert_includes cli('-i test/files/readable_test_file -s .*'), :skip
    
    skip_list = cli('-i test/files/readable_test_file -s .*')[:skip]
    assert_includes skip_list, '.*'
    assert_equal skip_list.size, 1

    skip_list = cli('-i test/files/readable_test_file -s .* --skip hello.md')[:skip]
    assert_includes skip_list, '.*'
    assert_includes skip_list, 'hello.md'
    assert_equal skip_list.size, 2

    skip_list = cli('-i test/files/readable_test_file -s .* --skip hello.md -s hello.md')[:skip]
    assert_includes skip_list, '.*'
    assert_includes skip_list, 'hello.md'
    assert_equal skip_list.size, 3 # it is not a set!
  end

  def test_unskip
    assert_includes cli('-i test/files/readable_test_file -u .*'), :unskip
    
    unskip_list = cli('-i test/files/readable_test_file -u .*')[:unskip]
    assert_includes unskip_list, '.*'
    assert_equal unskip_list.size, 1

    unskip_list = cli('-i test/files/readable_test_file -u .* --unskip hello.md')[:unskip]
    assert_includes unskip_list, '.*'
    assert_includes unskip_list, 'hello.md'
    assert_equal unskip_list.size, 2
  end

  def test_other_options
    assert_includes cli('-i test/files/readable_test_file -y'), :dry_run
    assert_includes cli('-i test/files/readable_test_file -q'), :quiet
  end

  def test_problematic_invocation
    e = assert_raises Pandocomatic::CLIError do
      cli('--some-unknown-option')
      cli('-Z')
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
