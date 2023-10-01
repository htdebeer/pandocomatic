# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'pandocomatic'

class TestPandocomaticYAML < Minitest::Test
  def test_no_vars
    yaml = <<~YAML
      ---
      key: value
      ...
    YAML

    hash = Pandocomatic::PandocomaticYAML.load yaml

    assert hash.key? 'key'
    assert_equal hash['key'], 'value'
  end

  def test_existing_var
    yaml = <<~YAML
      ---
      key: $(PATH)$
      ...
    YAML

    hash = Pandocomatic::PandocomaticYAML.load yaml

    assert hash.key? 'key'
    assert_equal hash['key'], ENV.fetch('PATH', nil)
  end

  def test_existing_vars
    yaml = <<~YAML
      ---
      key: $(PATH)$
      another: $(HOME)$
      ...
    YAML

    hash = Pandocomatic::PandocomaticYAML.load yaml

    assert hash.key? 'key'
    assert_equal hash['key'], ENV.fetch('PATH', nil)

    assert hash.key? 'another'
    assert_equal hash['another'], Dir.home
  end

  def test_non_existing_var
    yaml = <<~YAML
      ---
      key: $(NON_EXISTING_VARIABLE)$
      ...
    YAML

    assert_raises(
      Pandocomatic::TemplateError,
      "Environment variable 'NON_EXISTING_VARIABLE' does not exist: No substitution possible."
    ) do
      Pandocomatic::PandocomaticYAML.load yaml
    end
  end

  def test_load_file_with_var
    Dir.mktmpdir('vars') do |dir|
      path = File.join [dir, 'config.yaml']

      yaml = <<~YAML
        ---
        key: $(PATH)$
        ...
      YAML

      File.write(path, yaml)

      hash = Pandocomatic::PandocomaticYAML.load_file path

      assert hash.key? 'key'
      assert_equal hash['key'], ENV.fetch('PATH', nil)
    end
  end
end
