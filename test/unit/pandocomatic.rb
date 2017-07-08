require 'minitest/autorun'
require 'tmpdir'
require 'pandocomatic'

class TestPandocomaticRun < Minitest::Test

  def assert_files_equal(expected, generated)
    assert File.exist?(generated), generated
    assert_equal File.basename(expected), File.basename(generated), generated
    assert_equal File.read(expected).strip, File.read(generated).strip, generated
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
  
  def test_convert_hello_world
    Dir.mktmpdir('hello_world') do |dir|
      input = File.join ['example', 'hello_world.md']
      output = File.join [dir, 'hello_world.html']
      
      Pandocomatic::Pandocomatic.run "-i #{input} -o #{output}"

      example_output = File.join ['example', 'hello_world.html']
      assert_files_equal example_output, output
    end
  end


  def test_convert_blog
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

  def test_convert_wiki
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
  
  def test_convert_authored_wiki
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
  
  def test_convert_setup_cleanup
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

  def test_convert_site
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
end
