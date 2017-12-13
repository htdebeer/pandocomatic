require 'minitest/autorun'
require 'tmpdir'
require 'pandocomatic'

class TestPandocomaticRun < Minitest::Test

  def assert_files_equal(expected, generated)
    assert File.exist?(generated), generated
    assert_equal File.basename(expected), File.basename(generated), generated

    check_file_contents = ['.txt', '.md', '.html'].include? File.extname(generated)

    assert_equal File.read(expected).strip, File.read(generated).strip, generated if check_file_contents
  end

  def assert_directories_equal(expected, generated)
    assert_equal File.basename(expected), File.basename(generated)
    assert_equal Dir.entries(expected).size, Dir.entries(generated).size, expected

    Dir.foreach(expected).each do |entry|
      next if entry == '.' or entry == '..'
      expected_entry = File.join [expected, entry]
      generated_entry = File.join [generated, entry]

      if File.file? expected_entry
          assert_files_equal expected_entry, generated_entry
      elsif File.directory? expected_entry
        assert_directories_equal expected_entry, generated_entry
      else
        # ?
      end
    end
  end
  
  def test_convert_hello_world()
    Dir.mktmpdir('hello_world') do |dir|
      input = File.join ['example', 'hello_world.md']
      output = File.join [dir, 'hello_world.html']
      
      Pandocomatic::Pandocomatic.run "-i #{input} -o #{output}"

      example_output = File.join ['example', 'hello_world.html']
      assert_files_equal example_output, output
    end
  end

  def test_convert_with_dos_line_endings()
    Dir.mktmpdir('dos') do |dir|
      input = File.join ['example', 'dos.md']
      output = File.join [dir, 'dos.tex']
      
      Pandocomatic::Pandocomatic.run "-i #{input} -o #{output}"

      example_output = File.join ['example', 'dos.tex']
      assert_files_equal example_output, output
    end
  end

  def test_convert_blog()
    Dir.mktmpdir('blog') do |dir|
      input = File.join ['example', 'src', 'blog']
      data_dir = File.join ['example', 'data-dir']
      config = File.join ['example', 'blog.yaml']
      output = File.join [dir, 'blog']

      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"

      example_output = File.join ['example', 'dst', 'blog']
      assert_directories_equal example_output, output
    end
  end

  def test_convert_wiki()
    Dir.mktmpdir('wiki') do |dir|
      input = File.join ['example', 'src', 'wiki']
      data_dir = File.join ['example', 'data-dir']
      config = File.join ['example', 'wiki.yaml']
      output = File.join [dir, 'wiki']

      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"

      example_output = File.join ['example', 'dst', 'wiki']
      assert_directories_equal example_output, output
    end
  end
  
  def test_convert_authored_wiki()
    Dir.mktmpdir('auhtorized_wiki') do |dir|
      input = File.join ['example', 'src', 'authored_wiki']
      data_dir = File.join ['example', 'data-dir']
      config = File.join ['example', 'authored_wiki.yaml']
      output = File.join [dir, 'authored_wiki']

      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"

      example_output = File.join ['example', 'dst', 'authored_wiki']
      assert_directories_equal example_output, output
    end
  end
  
  def test_convert_wiki_with_arguments()
    Dir.mktmpdir('wiki_with_arguments') do |dir|
      input = File.join ['example', 'src', 'wiki_with_arguments']
      data_dir = File.join ['example', 'data-dir']
      config = File.join ['example', 'wiki_with_arguments.yaml']
      output = File.join [dir, 'wiki_with_arguments']

      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"

      example_output = File.join ['example', 'dst', 'wiki_with_arguments']
      assert_directories_equal example_output, output
    end
  end
  
  def test_convert_setup_cleanup()
    temp_file_name = 'pandocomatic_temporary_file.txt'
    temp_file_name_path = File.join ['/tmp', temp_file_name]


    # remove temp file
    if File.exist? temp_file_name_path
        File.delete temp_file_name_path
    end

    Dir.mktmpdir('setup_cleanup') do |dir|
      input = File.join ['example', 'src', 'setup-cleanup-wiki']
      data_dir = File.join ['example', 'data-dir']
      # setup.yaml is configured to create temp file
      config = File.join ['example', 'setup.yaml']
      output = File.join [dir, 'setup-cleanup-wiki']

      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"

      example_output = File.join ['example', 'dst', 'setup-cleanup-wiki']
      assert_directories_equal example_output, output

      assert File.exist? temp_file_name_path

      # cleanup.yaml is configured to remove temp file
      config = File.join ['example', 'cleanup.yaml']

      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"

      assert_directories_equal example_output, output

      refute File.exist? temp_file_name_path

    end
  end

  def test_convert_site()
    Dir.mktmpdir('site') do |dir|
      input = File.join ['example', 'src']
      data_dir = File.join ['example', 'data-dir']
      config = File.join ['example', 'site.yaml']
      output = File.join [dir, 'site']

      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"

      example_output = File.join ['example', 'dst', 'site']
      assert_directories_equal example_output, output
    end
  end

  def test_extending_templates()
    Dir.mktmpdir('twice_extended_wiki') do |dir|
      input = File.join ['example', 'src', 'twice_extended_wiki']
      data_dir = File.join ['example', 'data-dir']
      config = File.join ['example', 'twice_extended_wiki.yaml']
      output = File.join [dir, 'twice_extended_wiki']

      Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"

      example_output = File.join ['example', 'dst', 'twice_extended_wiki']
      assert_directories_equal example_output, output
    end
  end

  def test_converting_dir_to_odt()
    Dir.mktmpdir('twice_extended_wiki') do |dir|
      input = File.join ['example', 'src', 'odt_with_images']
      data_dir = File.join ['example', 'data-dir']
      config = File.join ['example', 'odt_with_images.yaml']
      output = File.join [dir, 'odt_with_images']

      _, err = capture_io do
          Pandocomatic::Pandocomatic.run "-d #{data_dir} -c #{config} -i #{input} -o #{output}"
      end

      assert_empty err

      example_output = File.join ['example', 'dst', 'odt_with_images']
      assert_directories_equal example_output, output
    end
  end

  def test_extensions()
    current_dir = Dir.getwd

    Dir.mktmpdir('extensions') do |dir|
      name = 'beamer_presentation'
      input = File.absolute_path(File.join(['example', 'extensions', "#{name}.md"]))

      Dir.chdir dir
      Pandocomatic::Pandocomatic.run "-i #{input}"

      assert File.exist?(File.join(dir, "#{name}.tex"))

      Dir.chdir current_dir
    end
  end
end
