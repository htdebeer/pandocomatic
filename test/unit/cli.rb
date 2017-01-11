require 'minitest/autorun'
require 'pandocomatic'

class TestPandocomatic < Minitest::Test

  GLOBAL_OPTIONS = {:data_dir=>nil, :quiet=>false, :dry_run=>false}
  CONVERT_OPTIONS = {:output=>nil, :input=>nil}
  GENERATE_OPTIONS = {:config => nil, :follow_links => true, :recursive => true, :skip => [], :output=>nil, :input=>nil}

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
      cli('convert')
      cli('convert -i -o')
      cli('convert -o out')
      cli('convert -o')
    end

    global = GLOBAL_OPTIONS.clone
    opts = CONVERT_OPTIONS.clone

    opts[:input] = 'test.md'
    assert_equal cli('convert test.md'), [global, 'convert', opts]

    global[:quiet] = true
    global[:quiet_given] = true
    assert_equal cli('-q convert test.md'), [global, 'convert', opts]
    global.delete :quiet_given
    global[:quiet] = false

    opts[:input_given] = true
    assert_equal cli('convert -i test.md'), [global, 'convert', opts]

    opts[:output] = 'test.html'
    opts[:output_given] = true
    assert_equal cli('convert -i test.md -o test.html'), [global, 'convert', opts]

    opts.delete :input_given
    assert_equal cli('convert -o test.html test.md'), [global, 'convert', opts]
  end

  def test_generate
    assert_raises Pandocomatic::PandocomaticError do
      cli('generate')
      cli('generate -i test/')
      cli('-d generate -o test/')
      cli('generate -c -i -o')
      cli('generate -r "ja" -o www src')
      cli('generate -r true -o www -i src')
      cli('generate -c pandocomatic.yaml -o www')
    end

    global = GLOBAL_OPTIONS.clone
    opts = GENERATE_OPTIONS.clone

    opts[:input] = 'src'
    opts[:input_given] = true
    opts[:output] = 'www'
    opts[:output_given] = true
    assert_equal cli('generate -i src -o www'), [global, 'generate', opts]

    opts.delete :input_given
    assert_equal cli('generate -o www src'), [global, 'generate', opts]

    opts[:config] = 'pandocomatic.yaml'
    opts[:config_given] = true
    assert_equal cli('generate -c pandocomatic.yaml -o www src'), [global, 'generate', opts]

    opts.delete :config_given
    opts[:config] = nil

    opts[:skip] = ['*.md']
    opts[:skip_given] = true
    assert_equal cli('generate -s *.md -o www src'), [global, 'generate', opts]
    opts[:skip] = ['*.md', '~*', '.*']
    assert_equal cli('generate -s *.md -o www -s ~* -s .* src'), [global, 'generate', opts]
  end

  def test_global_options
    assert_raises Pandocomatic::PandocomaticError do
      cli('convert -d')
      cli('-d pandocomatic ~/.pandoc -q convert')
    end
    # data-dir, quiet, dry-run
    global = GLOBAL_OPTIONS.clone
    global[:data_dir] = "pandocomatic"
    global[:data_dir_given] = true
    
    opts = CONVERT_OPTIONS.clone

    opts[:input] = 'test.md'
    assert_equal cli('-d pandocomatic convert test.md'), [global, 'convert', opts]

    global[:quiet] = true
    global[:quiet_given] = true
    assert_equal cli('-d pandocomatic -q convert test.md'), [global, 'convert', opts]

    global[:dry_run] = true
    global[:dry_run_given] = true
    assert_equal cli('-q -y -d pandocomatic convert test.md'), [global, 'convert', opts]
  end

end
