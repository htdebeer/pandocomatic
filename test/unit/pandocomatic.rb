# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'pandocomatic'

class TestPandocomaticRun < Minitest::Test
  def assert_files_equal(expected, generated)
    assert File.exist?(generated), generated
    assert_equal File.basename(expected), File.basename(generated), generated

    check_file_contents = ['.txt', '.md', '.html', '.tex'].include? File.extname(generated)

    assert_equal File.read(expected).strip, File.read(generated).strip, generated if check_file_contents
  end

  def assert_directories_equal(expected, generated)
    assert_equal File.basename(expected), File.basename(generated)
    assert_equal Dir.entries(expected).size, Dir.entries(generated).size, expected

    Dir.foreach(expected).each do |entry|
      next if (entry == '.') || (entry == '..')

      expected_entry = File.join [expected, entry]
      generated_entry = File.join [generated, entry]

      if File.file? expected_entry
        assert_files_equal expected_entry, generated_entry
      elsif File.directory? expected_entry
        assert_directories_equal expected_entry, generated_entry
      end
    end
  end

  def test_convert_hello_world
    Dir.mktmpdir('hello_world') do |dir|
      input = File.join ['example', 'hello_world.md']
      output = File.join [dir, 'hello_world.html']

      Pandocomatic::Pandocomatic.run "-i #{input} -o #{output}"

      example_output = File.join ['example', 'hello_world.html']
      assert_files_equal example_output, output
    end
  end

  def skip_test_convert_with_dos_line_endings
    Dir.mktmpdir('dos') do |dir|
      input = File.join ['example', 'dos.md']
      output = File.join [dir, 'dos.tex']

      Pandocomatic::Pandocomatic.run "-i #{input} -o #{output}"

      example_output = File.join ['example', 'dos.tex']
      assert_files_equal example_output, output
    end
  end

  def test_convert_with_only_comment_in_pandoc_metadata
    Dir.mktmpdir('only-comment-in-metadata') do |dir|
      input = File.join ['example', 'only-comment-in-metadata.md']
      output = File.join [dir, 'only-comment-in-metadata.html']

      Pandocomatic::Pandocomatic.run "-i #{input} -o #{output}"

      example_output = File.join ['example', 'only-comment-in-metadata.html']
      assert_files_equal example_output, output
    end
  end

  def test_convert_blog
    Dir.mktmpdir('blog') do |dir|
      input = File.join %w[example src blog]
      data_dir = File.join %w[example data-dir]
      config = File.join ['example', 'blog.yaml']
      output = File.join [dir, 'blog']

      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"

      example_output = File.join %w[example dst blog]
      assert_directories_equal example_output, output
    end
  end

  def test_convert_wiki
    Dir.mktmpdir('wiki') do |dir|
      input = File.join %w[example src wiki]
      data_dir = File.join %w[example data-dir]
      config = File.join ['example', 'wiki.yaml']
      output = File.join [dir, 'wiki']

      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"

      example_output = File.join %w[example dst wiki]
      assert_directories_equal example_output, output
    end
  end

  def test_convert_authored_wiki
    Dir.mktmpdir('auhtorized_wiki') do |dir|
      input = File.join %w[example src authored_wiki]
      data_dir = File.join %w[example data-dir]
      config = File.join ['example', 'authored_wiki.yaml']
      output = File.join [dir, 'authored_wiki']

      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"

      example_output = File.join %w[example dst authored_wiki]
      assert_directories_equal example_output, output
    end
  end

  def test_convert_wiki_with_arguments
    Dir.mktmpdir('wiki_with_arguments') do |dir|
      input = File.join %w[example src wiki_with_arguments]
      data_dir = File.join %w[example data-dir]
      config = File.join ['example', 'wiki_with_arguments.yaml']
      output = File.join [dir, 'wiki_with_arguments']

      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"

      example_output = File.join %w[example dst wiki_with_arguments]
      assert_directories_equal example_output, output
    end
  end

  def test_convert_setup_cleanup
    temp_file_name = 'pandocomatic_temporary_file.txt'
    temp_file_name_path = File.join ['/tmp', temp_file_name]

    # remove temp file
    FileUtils.rm_f temp_file_name_path

    Dir.mktmpdir('setup_cleanup') do |dir|
      input = File.join %w[example src setup-cleanup-wiki]
      data_dir = File.join %w[example data-dir]
      # setup.yaml is configured to create temp file
      config = File.join ['example', 'setup.yaml']
      output = File.join [dir, 'setup-cleanup-wiki']

      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"

      example_output = File.join %w[example dst setup-cleanup-wiki]
      assert_directories_equal example_output, output

      assert File.exist? temp_file_name_path

      # cleanup.yaml is configured to remove temp file
      config = File.join ['example', 'cleanup.yaml']

      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"

      assert_directories_equal example_output, output

      refute File.exist? temp_file_name_path
    end
  end

  def test_convert_site
    Dir.mktmpdir('site') do |dir|
      input = File.join %w[example src]
      data_dir = File.join %w[example data-dir]
      config = File.join ['example', 'site.yaml']
      output = File.join [dir, 'site']

      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"

      example_output = File.join %w[example dst site]
      assert_directories_equal example_output, output
    end
  end

  def test_extending_templates
    Dir.mktmpdir('twice_extended_wiki') do |dir|
      input = File.join %w[example src twice_extended_wiki]
      data_dir = File.join %w[example data-dir]
      config = File.join ['example', 'twice_extended_wiki.yaml']
      output = File.join [dir, 'twice_extended_wiki']

      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"

      example_output = File.join %w[example dst twice_extended_wiki]
      assert_directories_equal example_output, output
    end
  end

  def test_converting_dir_to_odt
    Dir.mktmpdir('twice_extended_wiki') do |dir|
      input = File.join %w[example src odt_with_images]
      data_dir = File.join %w[example data-dir]
      config = File.join ['example', 'odt_with_images.yaml']
      output = File.join [dir, 'odt_with_images']

      _, err = capture_io do
        Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"
      end

      assert_empty err

      example_output = File.join %w[example dst odt_with_images]
      assert_directories_equal example_output, output
    end
  end

  def skip_test_extensions
    current_dir = File.absolute_path Dir.getwd

    filenames = {
      'beamer_presentation.md' => 'beamer_presentation.tex',
      'beamer_presentation_plus_min_extensions.md' => 'beamer_presentation_plus_min_extensions.tex',
      'beamer_presentation_to_pdf.md' => 'beamer_presentation_to_pdf.pdf',
      'beamer_presentation_to_pdf_with_extension_option.md' => 'beamer_presentation_to_pdf_with_extension_option.pdf'
    }

    begin
      Dir.mktmpdir('extensions') do |dir|
        Dir.chdir dir
        filenames.each do |input_file, output_file|
          input = File.absolute_path(File.join([current_dir, 'example', 'extensions', input_file]))
          Pandocomatic::Pandocomatic.run "-i #{input}"
          assert File.exist?(File.join(dir, output_file))
        end
      end
    ensure
      Dir.chdir current_dir
    end
  end

  def test_convert_for_all_matching_templates
    Dir.mktmpdir('wiki') do |dir|
      input = File.join %w[example src wiki]
      data_dir = File.join %w[example data-dir]
      config = File.join ['example', 'all_templates.yaml']
      output = File.join [dir, 'all_templates']

      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"

      example_output = File.join %w[example dst all_templates]
      assert_directories_equal example_output, output
    end
  end

  def test_convert_for_all_matching_templates_with_renaming
    Dir.mktmpdir('wiki') do |dir|
      input = File.join %w[example src wiki]
      data_dir = File.join %w[example data-dir]
      config = File.join ['example', 'all_templates_with_renaming.yaml']
      output = File.join [dir, 'all_templates_with_renaming']

      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"

      example_output = File.join %w[example dst all_templates_with_renaming]
      assert_directories_equal example_output, output
    end
  end

  def test_convert_multiple_files
    Dir.mktmpdir('multiple_inputs') do |dir|
      inputs = [
        File.join(['example', 'multiple_input_files', 'book.md']),
        File.join(['example', 'multiple_input_files', 'chapter01.md']),
        File.join(['example', 'multiple_input_files', 'chapter02.md'])
      ]
      output = File.join [dir, 'multiple_inputs.html']

      Pandocomatic::Pandocomatic.run "#{inputs.map { |i| "-i #{i}" }.join(' ')} -o #{output}"

      example_output = File.join ['example', 'multiple_input_files', 'multiple_inputs.html']
      assert_files_equal example_output, output
    end
  end

  def test_convert_automatic_output_extension
    Dir.mktmpdir('automatic_output') do |_dir|
      input = File.join ['example', 'hello_world.md']
      assert_output(/hello_world\.html/) do
        Pandocomatic::Pandocomatic.run "-i #{input} --verbose"
      end
    end
  end

  def test_verbose_output
    Dir.mktmpdir('automatic_output') do |_dir|
      input = File.join ['example', 'hello_world.md']
      assert_output do
        Pandocomatic::Pandocomatic.run "-i #{input} --verbose"
      end
    end
  end

  def test_root_path_with_root_path
    # Build the output test files using absolute paths to output and root.
    # I.e.:
    #        cd example/root_paths
    #        ../../test/pandocomatic.rb -c config.yaml \
    #             -i src -d data \
    #             -o /home/pandocomatic-user/example/root_paths/www-with-root-path \
    #             -r /home/pandocomatic-user/example/root_paths/www-with-root-path
    # Otherwise it cannot find the paths
    # With root path:
    Dir.mktmpdir('with_root') do |dir|
      config = File.join ['example', 'root_paths', 'config.yaml']
      input = File.join %w[example root_paths src]
      output = File.join [dir, 'www-with-root-path']
      root_path = File.join [dir, 'www-with-root-path']
      data = File.join %w[example root_paths data]

      Pandocomatic::Pandocomatic.run "-c #{config} -i #{input} -o #{output} -r #{root_path} -d #{data}"

      example_output = File.join %w[example root_paths www-with-root-path]
      assert_directories_equal example_output, output
    end
  end

  def test_root_path_with_root_path_not_a_subdir
    # With root path not a subdir:
    Dir.mktmpdir('with_root') do |dir|
      config = File.join ['example', 'root_paths', 'config.yaml']
      input = File.join %w[example root_paths src]
      output = File.join [dir, 'www-with-non-subdir-root-path']
      root_path = File.join %w[some path]
      data = File.join %w[example root_paths data]

      Pandocomatic::Pandocomatic.run "-c #{config} -i #{input} -o #{output} -r #{root_path} -d #{data}"

      example_output = File.join %w[example root_paths www-with-non-subdir-root-path]
      assert_directories_equal example_output, output
    end
  end

  def test_root_path_without_root_path
    # Without root path:
    Dir.mktmpdir('without_root') do |dir|
      config = File.join ['example', 'root_paths', 'config.yaml']
      input = File.join %w[example root_paths src]
      output = File.join [dir, 'www-without-root-path']
      data = File.join %w[example root_paths data]

      Pandocomatic::Pandocomatic.run "-c #{config} -i #{input} -o #{output} -d #{data}"

      example_output = File.join %w[example root_paths www-without-root-path]
      assert_directories_equal example_output, output
    end
  end

  def test_empty_yaml_properties
    Dir.mktmpdir('empty-yaml-propertiess') do |dir|
      input = File.join ['example', 'empty-properties.md']
      output = File.join [dir, 'empty-properties.html']

      Pandocomatic::Pandocomatic.run "-i #{input} -o #{output}"

      example_output = File.join ['example', 'empty-properties.html']
      assert_files_equal example_output, output
    end
  end

  def test_global_inheritance
    Dir.mktmpdir('global-inheritance') do |dir|
      input = File.join ['example', 'inheritance', 'second.md']
      data_dir = File.join %w[example inheritance data-dir]
      config = File.join ['example', 'inheritance', 'first.yaml']

      output = File.join [dir, 'second.html']

      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"

      example_output = File.join ['example', 'inheritance', 'second.html']
      assert_files_equal example_output, output
    end
  end

  def test_global_inheritance_extending_non_existing_template
    Dir.mktmpdir('global-inheritance') do |dir|
      input = File.join ['example', 'inheritance', 'second.md']
      data_dir = File.join %w[example inheritance data-dir]
      config = File.join ['example', 'inheritance', 'broken.yaml']

      output = File.join [dir, 'second.html']
      $stderr = StringIO.new
      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"
      error = $stderr.string.strip
      expected = "WARNING: Unable to find templates [non-existing] while resolving the external template 'inherited-page' from configuration file '/home/pandocomatic-user/example/inheritance/broken.yaml'."
      assert_equal "#{expected}\n#{expected}", error
    end
  end

  def test_convert_to_stdout
    Dir.mktmpdir('hello_world') do |_dir|
      # capture STDOUT afresh
      $stdout = StringIO.new

      # Setup a simple conversion to STDOUT
      input = File.join ['example', 'hello_world.md']
      Pandocomatic::Pandocomatic.run "-i #{input} -s"
      output = $stdout.string.strip

      expected = '<p><em>Hello world!</em>, from <strong>pandocomatic</strong>.</p>'
      assert_equal expected, output
    end
  end

  def test_read_date_from_metadata
    Dir.mktmpdir('date_example') do |dir|
      input = File.join ['example', 'simple_date_in_metadata.md']
      data_dir = File.join %w[example data-dir]
      output = File.join [dir, 'date.md']

      _, err = capture_io do
        Pandocomatic::Pandocomatic.run "-i #{input} -d #{data_dir} -o #{output}"
      end

      assert_empty err
      expected = 'The date is: 2022-01-05'
      assert_equal expected, File.read(output).strip
    end
  end

  VARS = {
    'P_OUTPUT_FORMAT' => 'html',
    'P_AUTHOR' => 'Huub',
    'P_TITLE' => 'Hello with vars!'
  }.freeze

  def test_var_substitution
    VARS.each do |key, value|
      ENV[key] = value
    end

    Dir.mktmpdir('vars') do |dir|
      input = File.join ['example', 'hello_vars.md']
      config = File.join ['example', 'vars.yaml']
      output = File.join [dir, 'hello_vars.html']

      Pandocomatic::Pandocomatic.run "-i #{input} -c #{config} -o #{output}"

      example_output = File.join ['example', 'hello_vars.html']
      assert_files_equal example_output, output
    end

    VARS.each_key do |key|
      ENV.delete key if ENV.key? key
    end
  end

  def test_non_existing_var_substitution
    VARS.each_key do |key|
      ENV.delete key if ENV.key? key
    end

    Dir.mktmpdir('novars') do |dir|
      input = File.join ['example', 'hello_vars.md']
      config = File.join ['example', 'vars.yaml']
      output = File.join [dir, 'hello_vars.html']

      $stderr = StringIO.new

      begin
        Pandocomatic::Pandocomatic.run "-i #{input} -c #{config} -o #{output}"
      rescue Exception => e
        warn e
      end

      error = $stderr.string.strip

      expected_err = "Unable to load config file: '/home/pandocomatic-user/example/vars.yaml'. Environment variable 'P_OUTPUT_FORMAT' in '/home/pandocomatic-user/example/vars.yaml' does not exist: No substitution possible.
exit"
      assert_equal expected_err, error

      VARS.each do |key, value|
        ENV[key] = value unless key == 'P_TITLE'
      end

      $stderr = StringIO.new

      begin
        Pandocomatic::Pandocomatic.run "-i #{input} -c #{config} -o #{output}"
      rescue Exception => e
        warn e
      end

      error = $stderr.string.strip

      expected_err = "Expected to extract YAML metadata blocks from file '/home/pandocomatic-user/example/hello_vars.md', but did not succeed. Make sure '/home/pandocomatic-user/example/hello_vars.md' is a pandoc markdown file. Check YAML syntax of all metadata blocks; make sure that all horizontal lines have at least four (4) dashes.

Reported cause(s):
  Environment variable 'P_TITLE' in '/home/pandocomatic-user/example/hello_vars.md' does not exist: No substitution possible.
exit"
      assert_equal expected_err, error
    end

    VARS.each do |key, _|
      ENV.delete key if ENV.key? key
    end
  end

  def test_warn_and_ignore_pandoc_verbose
    Dir.mktmpdir('verbose') do |dir|
      input = File.join ['example', 'hello_verbose_world.md']
      output = File.join [dir, 'hello_verbose_world.html']
      assert_output(nil,
                    /WARNING: Ignoring the pandoc option \"--verbose\" because it might interfere with the working of pandocomatic. If you want to use \"--verbose\" anyway, use pandocomatic's feature toggle \"--enable pandoc-verbose\"./) do
        Pandocomatic::Pandocomatic.run "-i #{input} -o #{output}"
      end
      assert_output(nil,
                    "") do
        Pandocomatic::Pandocomatic.run "-i #{input} -o #{output} -e pandoc-verbose"
      end
    end
  end

  def test_warn_when_extracting_pandoc_yaml_metadata_fails
    Dir.mktmpdir('extract_yaml_metadata') do |dir|
      config = File.join ['example', 'extract_pandoc_metadata_from_docx.yaml']
      input = File.join ['example', 'hello_world.docx']
      output = File.join [dir, 'hello_world.tex']

      $stderr = StringIO.new

      begin
        Pandocomatic::Pandocomatic.run "-c #{config} -i #{input} -o #{output}"
      rescue Exception => e
        warn e
      end

      err = $stderr.string.strip
      expected = "Expected to extract YAML metadata blocks from file '/home/pandocomatic-user/example/hello_world.docx', but did not succeed. Make sure '/home/pandocomatic-user/example/hello_world.docx' is a pandoc markdown file. Check YAML syntax of all metadata blocks; make sure that all horizontal lines have at least four (4) dashes.

Reported cause(s):
  invalid byte sequence in UTF-8
exit"
      assert_equal expected, err
    end
  end

  def test_always_try_to_extract_metadata_from_markdown_files
    Dir.mktmpdir('extract_yaml_metadata') do |_dir|
      config = File.join ['example', 'extract_pandoc_metadata_from_docx.yaml']
      input = File.join ['example', 'hello_world_to_tex.md']

      $stdout = StringIO.new

      begin
        Pandocomatic::Pandocomatic.run "-c #{config} -i #{input} -s"
      rescue Exception => e
        warn e
      end

      output = $stdout.string.strip
      expected = '\\emph{Hello world!}, from \\textbf{pandocomatic}.'
      assert_equal expected, output
    end
  end

  def test_only_explicit_extending_templates
    Dir.mktmpdir('extend_metadata') do |dir|
      config = File.join ['example', 'extending_templates', 'config.yaml']
      data_dir = File.join ['example', 'extending_templates', 'data']
      input = File.join ['example', 'extending_templates', 'extended_template.md']
      output = File.join [dir, 'extended_template.tex']

      Pandocomatic::Pandocomatic.run "-c #{config} -d #{data_dir} -i #{input} -o #{output}"

      example_output = File.join ['example', 'extending_templates', 'extended_template.tex']

      assert_files_equal example_output, output
    end
  end
end
