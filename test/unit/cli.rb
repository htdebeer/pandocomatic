require 'minitest/autorun'
require 'pandocomatic'

class TestPandocomatic < Minitest::Test

  GLOBAL_OPTIONS = {:data_dir=>nil, :quiet=>false, :dry_run=>false}
  CONVERT_OPTIONS = {:output=>nil, :input=>nil}

  def setup
  end

  def cli(options_in)
    Pandocomatic::CLI.parse options_in
  end

  def test_cli_version
    assert_equal cli('--version'), [{}, 'version', {}]
    assert_equal cli('-v'), [{}, 'version', {}]
    assert_equal cli('version'), [{}, 'version', {}]
    assert_equal cli('version --go'), [{}, 'version', {}]
    
    # version overrides all other options and subcommands
    assert_equal cli('--version --dry-run'), [{}, 'version', {}]
    assert_equal cli('-v version'), [{}, 'version', {}]
    assert_equal cli('-v help'), [{}, 'version', {}]
    assert_equal cli('-v convert --data-dir "/path/to/dir"'), [{}, 'version', {}]
    assert_equal cli('-v generate --config -o "hi"'), [{}, 'version', {}]
    assert_equal cli('-q version --config -o "hi"'), [{}, 'version', {}]

    # general options are checked even if subcommand is version
    assert_raises Pandocomatic::PandocomaticError do
      # cannot find file, will be checked regardless of version subcommand
      cli('-d some_unexisting_file.yaml version') 
    end
  end

  def test_cli_help
    assert_equal cli('--help'), [{}, 'help', {:topic => 'default'}]
    assert_equal cli('-h'), [{}, 'help', {:topic => 'default'}]
    assert_equal cli('help'), [{}, 'help', {:topic => 'default'}]

    # help overrides all other options and subcommands, except for version,
    # which has priority over help. However, general options take precedence
    # over subcommands

    assert_equal cli('--help --dry-run'), [{}, 'help', {:topic => 'default'}]

    # Help for subcommands
    assert_equal cli('--help version'), [{}, 'help', {:topic => 'default'}]
    assert_equal cli('help version'), [{}, 'help', {:topic => 'version'}]
    assert_equal cli('help help'), [{}, 'help', {:topic => 'help'}]
    assert_equal cli('help convert'), [{}, 'help', {:topic => 'convert'}]
    assert_equal cli('help generate'), [{}, 'help', {:topic => 'generate'}]
    
    assert_equal cli('help generate convert'), [{}, 'help', {:topic => 'generate'}]
    assert_equal cli('-h version --config -o "hi"'), [{}, 'help', {:topic => 'default'}]
    
    assert_equal cli('help -q generate'), [{}, 'help', {:topic => 'default'}]
  end

  def test_convert
    assert_raises Pandocomatic::PandocomaticError do
      cli('convert') # no input file given
      cli('convert -i test.md') # input file does not exists or is not readable
      cli('convert -o out.html test.md') # outout file / input file do not exist
      cli('-d convert -i test.md') # data-dir missing
      cli('-d /data/dir convert -i test.md') # data-dir does not exist
    end
    
    infile = Tempfile.new('test.md')
    outfile = Tempfile.new('out.html')
    begin
      global = GLOBAL_OPTIONS.clone
      opts = CONVERT_OPTIONS.clone
     
      
      opts[:input] = infile.path
      assert_equal cli("convert #{infile.path}"), [global, 'convert', opts]

      global[:quiet] = true
      global[:quiet_given] = true
      assert_equal cli("-q convert #{infile.path}"), [global, 'convert', opts]
      global.delete :quiet_given
      global[:quiet] = false

      opts[:input_given] = true
      assert_equal cli("convert -i #{infile.path}"), [global, 'convert', opts]
      
      opts[:output] = outfile.path
      opts[:output_given] = true
      assert_equal cli("convert -i #{infile.path} -o #{outfile.path}"), [global, 'convert', opts]
      
      opts.delete :input_given
      assert_equal cli("convert -o #{outfile.path} #{infile.path}"), [global, 'convert', opts]
    ensure
      infile.close
      infile.unlink

      outfile.close
      outfile.unlink
    end
  end

  def test_generate
    assert_raises Pandocomatic::PandocomaticError do
      cli('generate') # no input dir given, no output dir given
      cli('generate -i test/') # input dir does not exist, no output dir
      cli('generate -o out/ test/') # output dir does not exist, nor input dir
      cli('-d convert -i test/') # data-dir missing, no output dir
      cli('-d /data/dir convert -i test/') # data-dir does not exist, no output dir
    end
    
    infile = Tempfile.new('test/')
    outfile = Tempfile.new('out/')
    configfile = Tempfile.new('config.yaml')
    begin
      global = GLOBAL_OPTIONS.clone
      opts = CONVERT_OPTIONS.clone
     
      
      opts[:input] = infile.path
      opts[:input_given] = true
      opts[:output] = outfile.path
      opts[:output_given] = true
      assert_equal cli("generate -i #{infile.path} -o #{outfile.path}"), [global, 'generate', opts]
      
      opts.delete :input_given
      assert_equal cli("convert -o #{outfile.path} #{infile.path}"), [global, 'generate', opts]

      # config file
      # follow links
      # recursive
      # skip
    ensure
      infile.close
      infile.unlink

      outfile.close
      outfile.unlink
    end
  end

  def test_global_options
    # data-dir, quiet, dry-run
  end

end
