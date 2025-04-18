# frozen_string_literal: true

# rubocop:disable Metrics
#--
# Copyright 2014—2024 Huub de Beer <Huub@heerdebeer.org>
#
# This file is part of pandocomatic.
#
# Pandocomatic is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# Pandocomatic is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with pandocomatic.  If not, see <http://www.gnu.org/licenses/>.
#++
module Pandocomatic
  require 'paru/pandoc'

  require_relative 'error/configuration_error'
  require_relative 'command/command'
  require_relative 'input'
  require_relative 'multiple_files_input'
  require_relative 'pandocomatic_yaml'
  require_relative 'path'
  require_relative 'template'

  # The default configuration for pandocomatic is read from
  # default_configuration.yaml.
  DEFAULT_CONFIG = PandocomaticYAML.load_file File.join(__dir__, 'default_configuration.yaml')

  # rubocop:disable Style/MutableConstant

  # The default settings for pandocomatic:
  # hidden files will always be skipped, as will pandocomatic
  # configuration files, unless explicitly set to not skip via the
  # "unskip" option
  DEFAULT_SETTINGS = {
    'skip' => ['.*', 'pandocomatic.yaml'],
    'extract-metadata-from' => [],
    'recursive' => true,
    'follow-links' => false,
    'match-files' => 'first'
  }
  # rubocop:enable Style/MutableConstant

  # Maps pandoc output formats to their conventional default extension.
  # Updated and in order of `pandoc --list-output-formats`.
  DEFAULT_EXTENSION = {
    'asciidoc' => 'adoc',
    'asciidoctor' => 'adoc',
    'beamer' => 'tex',
    'bibtex' => 'bib',
    'biblatex' => 'bib',
    'commonmark' => 'md',
    'context' => 'tex',
    'csljson' => 'json',
    'docbook' => 'docbook',
    'docbook4' => 'docbook',
    'docbook5' => 'docbook',
    'docx' => 'docx',
    'dokuwiki' => 'txt',
    'dzslides' => 'html',
    'epub' => 'epub',
    'epub2' => 'epub',
    'epub3' => 'epub',
    'fb2' => 'fb2',
    'gfm' => 'md',
    'haddock' => 'hs',
    'html' => 'html',
    'html4' => 'html',
    'html5' => 'html',
    'icml' => 'icml',
    'ipynb' => 'ipynb',
    'jats' => 'jats',
    'jats_archiving' => 'jats',
    'jats_articleauthoring' => 'jats',
    'jats_publishing' => 'jats',
    'jira' => 'jira',
    'json' => 'json',
    'latex' => 'tex',
    'man' => 'man',
    'markdown' => 'md',
    'markdown_github' => 'md',
    'markdown_mmd' => 'md',
    'markdown_phpextra' => 'md',
    'markdown_strict' => 'md',
    'media_wiki' => 'mediawiki',
    'ms' => 'ms',
    'muse' => 'muse',
    'native' => 'hs',
    'odt' => 'odt',
    'opendocument' => 'odt',
    'opml' => 'opml',
    'org' => 'org',
    'pdf' => 'pdf',
    'plain' => 'txt',
    'pptx' => 'pptx',
    'revealjs' => 'html',
    'rst' => 'rst',
    's5' => 'html',
    'slideous' => 'html',
    'slidy' => 'html',
    'tei' => 'tei',
    'texinfo' => 'texi',
    'textile' => 'textile',
    'xwiki' => 'xwiki',
    'zimwiki' => 'zimwiki'
  }.freeze

  # Pandoc's mapping from file extensions to pandoc source format. Taken from
  # https://github.com/jgm/pandoc/blob/main/src/Text/Pandoc/Format.hs
  PANDOCS_EXTENSION_TO_FORMAT_MAPPING = {
    '.Rmd' => 'markdown',
    '.adoc' => 'asciidoc',
    '.asciidoc' => 'asciidoc',
    '.bib' => 'biblatex',
    '.context' => 'context',
    '.csv' => 'csv',
    '.ctx' => 'context',
    '.db' => 'docbook',
    '.dj' => 'djot',
    '.docx' => 'docx',
    '.dokuwiki' => 'dokuwiki',
    '.epub' => 'epub',
    '.fb2' => 'fb2',
    '.htm' => 'html',
    '.html' => 'html',
    '.icml' => 'icml',
    '.ipynb' => 'ipynb',
    '.json' => 'json',
    '.latex' => 'latex',
    '.lhs' => 'markdown',
    '.ltx' => 'latex',
    '.markdown' => 'markdown',
    '.markua' => 'markua',
    '.md' => 'markdown',
    '.mdown' => 'markdown',
    '.mdwn' => 'markdown',
    '.mkd' => 'markdown',
    '.mkdn' => 'markdown',
    '.ms' => 'ms',
    '.muse' => 'muse',
    '.native' => 'native',
    '.odt' => 'odt',
    '.opml' => 'opml',
    '.org' => 'org',
    '.pptx' => 'pptx',
    '.ris' => 'ris',
    '.roff' => 'ms',
    '.rst' => 'rst',
    '.rtf' => 'rtf',
    '.s5' => 's5',
    '.t2t' => 't2t',
    '.tei' => 'tei',
    '.tex' => 'latex',
    '.texi' => 'texinfo',
    '.texinfo' => 'texinfo',
    '.text' => 'markdown',
    '.textile' => 'textile',
    '.tsv' => 'tsv',
    '.typ' => 'typst',
    '.txt' => 'markdown',
    '.wiki' => 'mediawiki',
    '.xhtml' => 'html',
    '.1' => 'man',
    '.2' => 'man',
    '.3' => 'man',
    '.4' => 'man',
    '.5' => 'man',
    '.6' => 'man',
    '.7' => 'man',
    '.8' => 'man',
    '.9' => 'man'
  }.freeze

  # Configuration models a pandocomatic configuration.
  class Configuration
    attr_reader :input, :config_files, :data_dir, :root_path

    # Pandocomatic's default configuration file
    CONFIG_FILE = 'pandocomatic.yaml'

    # Create a new Configuration instance based on the command-line options
    def initialize(options, input)
      data_dirs = determine_data_dirs options
      @options = options
      @data_dir = data_dirs.first
      @settings = DEFAULT_SETTINGS
      @templates = {}
      @convert_patterns = {}

      load_configuration_hierarchy options, data_dirs

      @input = if input.nil? || input.empty?
                 nil
               elsif input.size > 1
                 MultipleFilesInput.new(input, self)
               else
                 Input.new(input)
               end

      @output = if output?
                  options[:output]
                elsif to_stdout? options
                  Tempfile.new(@input.base) unless @input.nil?
                elsif @input.is_a? Input
                  @input.base
                end

      @root_path = Path.determine_root_path options

      # Extend the command classes by setting the source tree root
      # directory, and the options quiet and dry-run, which are used when
      # executing a command: if dry-run the command is not actually
      # executed and if quiet the command is not printed to STDOUT
      Command.reset(self)
    end

    # Read a configuration file and create a pandocomatic configuration object
    #
    # @param [String] filename Path to the configuration yaml file
    # @return [Configuration] a pandocomatic configuration object
    def load(filename)
      begin
        path = File.absolute_path filename
        settings = PandocomaticYAML.load_file path
        if settings['settings'] && settings['settings']['data-dir']
          data_dir = settings['settings']['data-dir']
          src_dir = File.dirname filename
          @data_dir = if data_dir.start_with? '.'
                        File.absolute_path data_dir, src_dir
                      else
                        data_dir
                      end
        end
      rescue StandardError => e
        raise ConfigurationError.new(:unable_to_load_config_file, e, filename)
      end

      configure settings, filename
    end

    # Update this configuration with a configuration file and return a new
    # configuration
    #
    # @param [String] filename path to the configuration file
    #
    # @return [Configuration] a new configuration
    def reconfigure(filename)
      settings = PandocomaticYAML.load_file filename
      new_config = Marshal.load(Marshal.dump(self))
      new_config.configure settings, filename, recursive: true
      new_config
    rescue StandardError => e
      raise ConfigurationError.new(:unable_to_load_config_file, e, filename)
    end

    #  Create a copy of this configuration
    #
    #  @return [Configuration] copy
    def clone
      Marshal.load(Marshal.dump(self))
    end

    # Configure pandocomatic based on a settings Hash
    #
    # @param settings [Hash] a settings Hash to mixin in this
    # @param path [String] the configuration's path or filename
    # Configuration.
    # @param recursive [Boolean] should this configuration be configured
    # recursively? I.e., when running on a directory?
    def configure(settings, path, recursive: false)
      reset_settings settings['settings'] if settings.key? 'settings'

      return unless settings.key? 'templates'

      settings['templates'].each do |name, template|
        reset_template Template.new(name, template, path), recursive:
      end
    end

    # Convert this Configuration to a String
    #
    # @return [String]
    def to_s
      marshal_dump
    end

    # Is the dry run CLI option given?
    #
    # @return [Boolean]
    def dry_run?
      @options[:dry_run_given] and @options[:dry_run]
    end

    # Is the stdout CLI option given?
    #
    # @return [Boolean]
    def stdout?
      !@options.nil? and @options[:stdout_given] and @options[:stdout]
    end

    # Is the verbose CLI option given?
    #
    # @return [Boolean]
    def verbose?
      @options[:verbose_given] and @options[:verbose]
    end

    # Run pandocomatic in quiet mode?
    #
    # @return [Boolean]
    def quiet?
      [verbose?, dry_run?].none?
    end

    # Is the modified only CLI option given?
    #
    # @return [Boolean]
    def modified_only?
      @options[:modified_only_given] and @options[:modified_only]
    end

    # Is the version CLI option given?
    #
    # @return [Boolean]
    def show_version?
      @options[:version_given]
    end

    # Is the help CLI option given?
    #
    # @return [Boolean]
    def show_help?
      @options[:help_given]
    end

    # Is the data dir CLI option given?
    #
    # @return [Boolean]
    def data_dir?
      @options[:data_dir_given]
    end

    # Is the root path CLI option given?
    #
    # @return [Boolean]
    def root_path?
      @options[:root_path_given]
    end

    # Is the config CLI option given?
    #
    # @return [Boolean]
    def config?
      @options[:config_given]
    end

    # Should given feature be enabled?
    #
    # @param feature [Symbol] feature toggle to check
    # @return [Boolean]
    def feature_enabled?(feature)
      @options[:enable_given] and Pandocomatic::FEATURES.include?(feature) and @options[:enable].include?(feature)
    end

    # Is the output CLI option given and can that output be used?
    #
    # @return [Boolean]
    def output?
      !@options.nil? and @options[:output_given] and @options[:output]
    end

    # Get the output file name
    #
    # @return [String]
    attr_reader :output

    # Get the source root directory
    #
    # @return [String]
    def src_root
      @input&.absolute_path
    end

    # Have input CLI options be given?
    def input?
      @options[:input_given]
    end

    # Get the input file name
    #
    # @return [String]
    def input_file
      if @input.nil?
        nil
      else
        @input.name
      end
    end

    # Is this Configuration for converting directories?
    #
    # @return [Boolean]
    def directory?
      !@input.nil? and @input.directory?
    end

    # Clean up this configuration. This will remove temporary files
    # created for the conversion process guided by this Configuration.
    def clean_up!
      # If a temporary file has been created while concatenating
      # multiple input files, ensure it is removed.
      @input.destroy! if @input.is_a? MultipleFilesInput
    end

    # Should the source file be skipped given this Configuration?
    #
    # @param src [String] path to a source file
    # @return [Boolean] True if this source file matches the pattern in
    #   the 'skip' setting, false otherwise.
    def skip?(src)
      if @settings.key? 'skip'
        @settings['skip'].any? { |glob| File.fnmatch glob, File.basename(src) }
      else
        false
      end
    end

    # Get a pandoc metadata object for given source file and template.
    #
    # @param src [String] path to source file
    # @param template_name [String] template used; optional parameter
    # @return [PandocMetadata] Pandoc's metadata for given file and template.
    def get_metadata(src, template_name = nil)
      if extract_metadata_from? src
        PandocMetadata.load_file src
      else
        src_format = nil

        # Determine source format based on template
        if template_name && @templates.key?(template_name) && @templates[template_name].pandoc?
          pandoc = @templates[template_name].pandoc
          src_format = pandoc['from'] if pandoc.key? 'from'
        end

        if src_format.nil?
          # Determine source format based on extension like pandoc does.
          # See https://github.com/jgm/pandoc/blob/main/src/Text/Pandoc/Format.hs
          # for that mapping
          src_extension = File.extname src
          src_format = PANDOCS_EXTENSION_TO_FORMAT_MAPPING[src_extension]
        end

        if !src_format || src_format == 'markdown'
          # Behave like pandoc: If no source format can be determined, assume markdown
          PandocMetadata.load_file src
        else
          PandocMetadata.empty src_format
        end
      end
    end

    # Should the source file be converted given this Configuration?
    #
    # @param src [String] True if this source file matches the 'glob'
    #   patterns in a template, false otherwise.
    def convert?(src)
      @convert_patterns.values.flatten.any? { |glob| File.fnmatch glob, File.basename(src) }
    end

    # Should pandocomatic be run recursively given this Configuration?
    #
    # @return [Boolean] True if the setting 'recursive' is true, false
    #   otherwise
    def recursive?
      @settings.key? 'recursive' and @settings['recursive']
    end

    # Should pandocomatic follow symbolic links given this Configuration?
    #
    # @return [Boolean] True if the setting 'follow_links' is true, false
    #   otherwise
    def follow_links?
      @settings.key? 'follow_links' and @settings['follow_links']
    end

    # Should pandocomatic convert a file with all matching templates or
    # only with the first matching template? Note. A 'use-template'
    # statement in a document will overrule this setting.
    #
    # @return [Boolean] True if the setting 'match-files' is 'all', false
    # otherwise.
    def match_all_templates?
      @settings.key? 'match-files' and @settings['match-files'] == 'all'
    end

    # Should pandocomatic convert a file with the first matching templates
    # or with all matching templates? Note. Multiple 'use-template'
    # statements in a document will overrule this setting.
    #
    # @return [Boolean] True if the setting 'match-files' is 'first', false
    # otherwise.
    def match_first_template?
      @settings.key? 'match-files' and @settings['match-files'] == 'first'
    end

    # Set the extension of the destination file given this Confguration,
    # template, and metadata
    #
    # @param dst [String] path to a destination file
    # @param template_name [String] the name of the template used to
    #   convert to destination
    # @param metadata [PandocMetadata] the metadata in the source file
    def set_extension(dst, template_name, metadata)
      dir = File.dirname dst
      ext = File.extname dst
      basename = File.basename dst, ext
      File.join dir, "#{basename}.#{find_extension(template_name, metadata)}"
    end

    # Set the destination file given this Confguration,
    # template, and metadata
    #
    # @param dst [String] path to a destination file
    # @param template_name [String] the name of the template used to
    #   convert to destination
    # @param metadata [PandocMetadata] the metadata in the source file
    def set_destination(dst, template_name, metadata)
      return dst if dst.is_a? Tempfile

      dir = File.dirname dst

      # Use the output option when set.
      determine_output_in_pandoc = lambda do |pandoc|
        if pandoc.key? 'output'
          output = pandoc['output']
          unless output.start_with? '/'
            # Put it relative to the current directory
            output = File.join dir, output
          end
          output
        end
      end

      # Output options in pandoc property have precedence
      destination = determine_output_in_pandoc.call metadata.pandoc_options
      rename_script = metadata.pandoc_options['rename']

      # Output option in template's pandoc property is next
      if destination.nil? && !template_name.nil? && !template_name.empty? && @templates[template_name].pandoc?
        pandoc = @templates[template_name].pandoc
        destination = determine_output_in_pandoc.call pandoc
        rename_script ||= pandoc['rename']
      end

      # Else fall back to taking the input file as output file with the
      # extension updated to the output format
      if destination.nil?
        destination = set_extension dst, template_name, metadata

        destination = rename_destination(rename_script, destination) unless rename_script.nil?
      end

      # If there is a single file input without output specified, set
      # the output now that we know what the output filename is.
      @output = destination.delete_prefix './' unless output?

      destination
    end

    # Find the extension of the destination file given this Confguration,
    # template, and metadata
    #
    # @param template_name [String] the name of the template used to
    #   convert to destination
    # @param metadata [PandocMetadata] the metadata in the source file
    #
    # @return [String] the extension to use for the destination file
    def find_extension(template_name, metadata)
      extension = 'html'

      # Pandoc supports enabling / disabling extensions
      # using +EXTENSION and -EXTENSION
      strip_extensions = ->(format) { format.split(/[+-]/).first }
      use_extension = lambda do |pandoc|
        pandoc['use-extension'] if pandoc.key? 'use-extension'
      end

      if template_name.nil? || template_name.empty?
        ext = use_extension.call metadata.pandoc_options
        if !ext.nil?
          extension = ext
        elsif metadata.pandoc_options.key? 'to'
          extension = strip_extensions.call(metadata.pandoc_options['to'])
        end
      elsif @templates[template_name].pandoc?
        pandoc = @templates[template_name].pandoc
        ext = use_extension.call pandoc

        if !ext.nil?
          extension = ext
        elsif pandoc.key? 'to'
          extension = strip_extensions.call(pandoc['to'])
        end
      end

      DEFAULT_EXTENSION[extension] || extension
    end

    # Is filename a markdown file according to its extension?
    #
    # @param filename [String] the filename to check
    # @return [Boolean] True if filename has a markdown extension.
    def markdown_file?(filename)
      if filename.nil?
        false
      else
        ext = File.extname(filename).delete_prefix('.')
        DEFAULT_EXTENSION.key(ext) == 'markdown'
      end
    end

    # Is there a template with template_name in this Configuration?
    #
    # @param template_name [String] a template's name
    #
    # @return [Boolean] True if there is a template with name equal to
    #   template_name in this Configuration
    def template?(template_name)
      @templates.key? template_name
    end

    # Get the template with template_name from this Configuration
    #
    # @param template_name [String] a template's name
    #
    # @return [Template] The template with template_name.
    def get_template(template_name)
      @templates[template_name]
    end

    # Determine the template to use with this source document given this
    # Configuration.
    #
    # @param src [String] path to the source document
    # @return [String] the template's name to use
    def determine_template(src)
      @convert_patterns.select do |_, globs|
        globs.any? { |glob| File.fnmatch glob, File.basename(src) }
      end.keys.first
    end

    # Determine the templates to use with this source document given this
    # Configuration.
    #
    # @param src [String] path to the source document
    # @return [Array[String]] the template's name to use
    def determine_templates(src)
      matches = @convert_patterns.select do |_, globs|
        globs.any? { |glob| File.fnmatch glob, File.basename(src) }
      end.keys

      if matches.empty?
        []
      elsif match_all_templates?
        matches
      else
        [matches.first]
      end
    end

    private

    # Reset the settings for pandocomatic based on a new settings Hash
    #
    # @param settings [Hash] the new settings to use to reset the settings in
    #   this Configuration with.
    def reset_settings(settings)
      settings.each do |setting, value|
        case setting
        when 'skip'
          @settings['skip'] = @settings['skip'].concat(value).uniq
        when 'extract-metadata-from'
          @settings['extract-metadata-from'] = @settings['extract-metadata-from'].concat(value).uniq
        when 'data-dir'
          next # skip data-dir setting; is set once in initialization
        else
          @settings[setting] = value
        end
      end
    end

    # Resolve the templates the templates extends and mixes them in, in
    # order of occurrence.
    #
    # @param template [Template] the template to extend
    # @return [Template] the resolved template
    def extend_template(template)
      resolved_template = Template.new template.name

      missing = []

      template.extends.each do |name|
        if @templates.key? name
          resolved_template.merge! Template.clone(@templates[name])
        else
          missing << name
        end
      end

      unless missing.empty?
        if template.internal?
          warn "WARNING: Unable to find templates [#{missing.join(', ')}] while resolving internal template."
        else
          warn "WARNING: Unable to find templates [#{missing.join(', ')}] while resolving " \
               "the external template '#{template.name}' from configuration file '#{template.path}'."
        end
      end

      resolved_template.merge! template
      resolved_template
    end

    # Reset the template with same name in this Configuration based on a new
    # template
    #
    # @param template [Template] the template to use to update the template in
    #   this Configuration with
    # @param recursive [Boolean] should this configuration be configured
    # recursively? I.e., when running on a directory?
    def reset_template(template, recursive: false)
      name = template.name
      extended_template = extend_template template

      if recursive && @templates.key?(name)
        @templates[name].merge! extended_template
      else
        @templates[name] = extended_template
      end

      @convert_patterns[name] = extended_template.glob if extended_template.glob?
    end

    # Rename path by using rename script. If script fails somehow, warn
    # and return the original destination.
    #
    # @param rename_script [String] absolute path to script to run
    # @param dst [String] original destination to rename
    def rename_destination(rename_script, dst)
      script = Path.update_path(self, rename_script)

      command, *parameters = script.shellsplit # split on spaces unless it is preceded by a backslash

      unless File.exist? command
        command = Path.which(command)
        script = "#{command} #{parameters.join(' ')}"

        raise ProcessorError.new(:script_does_not_exist, nil, command) if command.nil?
      end

      raise ProcessorError.new(:script_is_not_executable, nil, command) unless File.executable? command

      begin
        renamed_dst = Processor.run(script, dst)
        if !renamed_dst.nil? && !renamed_dst.empty?
          renamed_dst.strip
        else
          raise StandardError, new("Running rename script '#{script}' on destination '#{dst}' " \
                                   'did not result in a renamed destination.')
        end
      rescue StandardError => e
        ProcessorError.new(:error_processing_script, e, [script, dst])
        dst
      end
    end

    def marshal_dump
      [@data_dir, @settings, @templates, @convert_patterns, @root_path]
    end

    def marshal_load(array)
      @data_dir, @settings, @templates, @convert_patterns, @root_path = array
    end

    def to_stdout?(options)
      !options.nil? and options[:stdout_given] and options[:stdout]
    end

    # Read a list of configuration files and create a
    # pandocomatic object that mixes templates from most generic to most
    # specific.
    def load_configuration_hierarchy(options, data_dirs)
      # Read and mixin templates from most generic config file to most
      # specific, thus in reverse order.
      @config_files = determine_config_files(options, data_dirs).reverse
      @config_files.each do |config_file|
        configure PandocomaticYAML.load_file(config_file), config_file
      rescue StandardError => e
        raise ConfigurationError.new(:unable_to_load_config_file, e, config_file)
      end

      load @config_files.last
    end

    def determine_config_files(options, data_dirs = [])
      config_files = []
      # Get config file from option, if any
      config_files << options[:config] if options[:config_given]

      # Get config file in each data_dir
      data_dirs.each do |data_dir|
        config_files << File.join(data_dir, CONFIG_FILE) if Dir.entries(data_dir).include? CONFIG_FILE
      end

      # Default configuration file distributes with pandocomatic
      config_files << File.join(__dir__, 'default_configuration.yaml')

      config_files.map do |config_file|
        path = File.absolute_path config_file

        raise ConfigurationError.new(:config_file_does_not_exist, nil, path) unless File.exist? path
        raise ConfigurationError.new(:config_file_is_not_a_file, nil, path) unless File.file? path
        raise ConfigurationError.new(:config_file_is_not_readable, nil, path) unless File.readable? path

        path
      end
    end

    def determine_config_file(options, data_dir = Dir.pwd)
      determine_config_files(options, [data_dir]).first
    end

    # Determine all data directories to use
    def determine_data_dirs(options)
      data_dirs = []

      # Data dir from CLI option
      data_dirs << options[:data_dir] if options[:data_dir_given]

      # Pandoc's default data dir
      begin
        data_dir = Paru::Pandoc.info[:data_dir]

        # If pandoc's data dir does not exist, however, fall back
        # to the current directory
        data_dirs << if File.exist? File.absolute_path(data_dir)
                       data_dir
                     else
                       Dir.pwd
                     end
      rescue Paru::Error => e
        # If pandoc cannot be run, continuing probably does not work out
        # anyway, so raise pandoc error
        raise PandocError.new(:error_running_pandoc, e, data_dir)
      rescue StandardError
        # Ignore error and use the current working directory as default working directory
        data_dirs << Dir.pwd
      end

      # check if data directories do exist and are readable
      data_dirs.uniq.map do |dir|
        path = File.absolute_path dir

        raise ConfigurationError.new(:data_dir_does_not_exist, nil, path) unless File.exist? path
        raise ConfigurationError.new(:data_dir_is_not_a_directory, nil, path) unless File.directory? path
        raise ConfigurationError.new(:data_dir_is_not_readable, nil, path) unless File.readable? path

        path
      end
    end

    # Should we try to extract pandoc YAML metadata from source file?
    def extract_metadata_from?(src)
      if @settings.key? 'extract-metadata-from'
        @settings['extract-metadata-from'].any? { |glob| File.fnmatch glob, File.basename(src) }
      else
        false
      end
    end
  end
end
# rubocop:enable Metrics
