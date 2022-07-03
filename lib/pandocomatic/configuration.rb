#--
# Copyright 2014—2022 Huub de Beer <Huub@heerdebeer.org>
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

    require 'yaml'
    require 'paru/pandoc'
    
    require_relative './error/configuration_error.rb'
    require_relative './command/command.rb'
    require_relative './input.rb'
    require_relative './multiple_files_input.rb'
    require_relative './template.rb'

    # The default configuration for pandocomatic is read from
    # default_configuration.yaml.
    DEFAULT_CONFIG = YAML.load_file File.join(__dir__, 'default_configuration.yaml')

    # Maps pandoc output formats to their conventional default extension.
    # Updated and in order of `pandoc --list-output-formats`.
    DEFAULT_EXTENSION = {
        'asciidoc'                => 'adoc',
        'asciidoctor'             => 'adoc',
        'beamer'                  => 'tex',
        'bibtex'                  => 'bib',
        'biblatex'                => 'bib',
        'commonmark'              => 'md',
        'context'                 => 'tex',
        'csljson'                 => 'json',
        'docbook'                 => 'docbook',
        'docbook4'                => 'docbook',
        'docbook5'                => 'docbook',
        'docx'                    => 'docx',
        'dokuwiki'                => 'txt',
        'dzslides'                => 'html',
        'epub'                    => 'epub',
        'epub2'                   => 'epub',
        'epub3'                   => 'epub',
        'fb2'                     => 'fb2',
        'gfm'                     => 'md',
        'haddock'                 => 'hs',
        'html'                    => 'html',
        'html4'                   => 'html',
        'html5'                   => 'html',
        'icml'                    => 'icml',
        'ipynb'                   => 'ipynb',
        'jats'                    => 'jats',
        'jats_archiving'          => 'jats',
        'jats_articleauthoring'   => 'jats',
        'jats_publishing'         => 'jats',
        'jira'                    => 'jira',
        'json'                    => 'json',
        'latex'                   => 'tex',
        'man'                     => 'man',
        'markdown'                => 'md',
        'markdown_github'         => 'md',
        'markdown_mmd'            => 'md',
        'markdown_phpextra'       => 'md',
        'markdown_strict'         => 'md',
        'media_wiki'              => 'mediawiki',
        'ms'                      => 'ms',
        'muse'                    => 'muse',
        'native'                  => 'hs',
        'odt'                     => 'odt',
        'opendocument'            => 'odt',
        'opml'                    => 'opml',
        'org'                     => 'org',
        'pdf'                     => 'pdf',
        'plain'                   => 'txt',
        'pptx'                    => 'pptx',
        'revealjs'                => 'html',
        'rst'                     => 'rst',
        's5'                      => 'html',
        'slideous'                => 'html',
        'slidy'                   => 'html',
        'tei'                     => 'tei',
        'texinfo'                 => 'texi',
        'textile'                 => 'textile',
        'xwiki'                   => 'xwiki',
        'zimwiki'                 => 'zimwiki'
    }

    # Indicator for paths that should be treated as "relative to the root
    # path". These paths start with this ROOT_PATH_INDICATOR.
    ROOT_PATH_INDICATOR = "$ROOT$"

    # A Configuration object models a pandocomatic configuration.
    class Configuration

        attr_reader :input, :config_files

        # Pandocomatic's default configuration file
        CONFIG_FILE = 'pandocomatic.yaml'

        # Create a new Configuration instance based on the command-line options
        def initialize options, input
            @options = options
            data_dirs = determine_data_dirs options
            @data_dir = data_dirs.first

            # hidden files will always be skipped, as will pandocomatic
            # configuration files, unless explicitly set to not skip via the
            # "unskip" option
            @settings = {
                'skip' => ['.*', 'pandocomatic.yaml'],
                'recursive' => true,
                'follow-links' => false,
                'match-files' => 'first'
            } 

            @templates = {}
            @convert_patterns = {}

            load_configuration_hierarchy options, data_dirs
            
            @input = if input.nil? or input.empty? then
                         nil
                     elsif 1 < input.size then
                         MultipleFilesInput.new(input, self)
                     else
                         Input.new(input)
                     end

            @output = if output? then 
                          options[:output] 
                      elsif to_stdout? options then
                          Tempfile.new(@input.base)
                      elsif @input.is_a? Input then 
                          @input.base
                      else 
                          nil 
                      end

            @root_path = determine_root_path options

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
                settings = YAML.load_file path
                if settings['settings'] and settings['settings']['data-dir'] then
                    data_dir = settings['settings']['data-dir']
                    src_dir = File.dirname filename
                    if data_dir.start_with? '.' then
                        @data_dir = File.absolute_path data_dir, src_dir
                    else
                        @data_dir = data_dir
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
            begin
                settings = YAML.load_file filename
                new_config = Marshal.load(Marshal.dump(self))
                new_config.configure settings, filename
                new_config
            rescue StandardError => e
                raise ConfigurationError.new(:unable_to_load_config_file, e, filename)
            end
        end

        # Configure pandocomatic based on a settings Hash
        #
        # @param settings [Hash] a settings Hash to mixin in this
        # @param path [String] the configuration's path or filename
        # Configuration.
        def configure(settings, path)
            reset_settings settings['settings'] if settings.has_key? 'settings'
            if settings.has_key? 'templates' then
                settings['templates'].each do |name, template|
                    reset_template Template.new(name, template, path)
                end
            end
        end

        # Convert this Configuration to a String
        #
        # @return [String]
        def to_s()
            marshal_dump
        end

        # Is the dry run CLI option given?
        #
        # @return [Boolean]
        def dry_run?() 
            @options[:dry_run_given] and @options[:dry_run]
        end

        # Is the stdout CLI option given?
        #
        # @return [Boolean]
        def stdout?()
          not @options.nil? and @options[:stdout_given] and @options[:stdout]
        end

        # Is the verbose CLI option given?
        # 
        # @return [Boolean]
        def verbose?()
          @options[:verbose_given] and @options[:verbose]
        end

        # Is the debug CLI option given?
        #
        # @return [Boolean]
        def debug?()
            @options[:debug_given] and @options[:debug]
        end

        # Run pandocomatic in quiet mode? 
        #
        # @return [Boolean]
        def quiet?()
          [verbose?, debug?, dry_run?].none?
        end

        # Is the modified only CLI option given?
        #
        # @return [Boolean]
        def modified_only?()
            @options[:modified_only_given] and @options[:modified_only]
        end

        # Is the version CLI option given?
        #
        # @return [Boolean]
        def show_version?()
            @options[:version_given]
        end

        # Is the help CLI option given?
        #
        # @return [Boolean]
        def show_help?()
            @options[:help_given]
        end

        # Is the data dir CLI option given?
        #
        # @return [Boolean]
        def data_dir?()
            @options[:data_dir_given]
        end

        # Is the root path CLI option given?
        #
        # @return [Boolean]
        def root_path?()
            @options[:root_path_given]
        end

        # Is the config CLI option given?
        #
        # @return [Boolean]
        def config?()
            @options[:config_given]
        end

        # Is the output CLI option given and can that output be used?
        #
        # @return [Boolean]
        def output?()
          not @options.nil? and @options[:output_given] and @options[:output]
        end

        # Get the output file name
        #
        # @return [String]
        def output()
            @output
        end

        # Get the source root directory
        #
        # @return [String]
        def src_root()  
            if @input.nil? then nil else @input.absolute_path end
        end

        # Have input CLI options be given?
        def input?()
            @options[:input_given]
        end

        # Get the input file name
        #
        # @return [String]
        def input_file()
            if @input.nil? then
                nil
            else
                @input.name
            end
        end

        # Is this Configuration for converting directories?
        #
        # @return [Boolean]
        def directory?()
            not @input.nil? and @input.directory?
        end

        # Clean up this configuration. This will remove temporary files
        # created for the conversion process guided by this Configuration.
        def clean_up!()
            # If a temporary file has been created while concatenating
            # multiple input files, ensure it is removed.
            if @input.is_a? MultipleFilesInput then
                @input.destroy!
            end
        end

        # Should the source file be skipped given this Configuration?
        #
        # @param src [String] path to a source file
        # @return [Boolean] True if this source file matches the pattern in
        #   the 'skip' setting, false otherwise.
        def skip?(src)
            if @settings.has_key? 'skip' then
                @settings['skip'].any? {|glob| File.fnmatch glob, File.basename(src)}
            else
                false
            end
        end

        # Should the source file be converted given this Configuration?
        #
        # @param src [String] True if this source file matches the 'glob'
        #   patterns in a template, false otherwise.
        def convert?(src)
            @convert_patterns.values.flatten.any? {|glob| File.fnmatch glob, File.basename(src)}
        end

        # Should pandocomatic be run recursively given this Configuration?
        #
        # @return [Boolean] True if the setting 'recursive' is true, false
        #   otherwise
        def recursive?()
            @settings.has_key? 'recursive' and @settings['recursive']
        end

        # Should pandocomatic follow symbolic links given this Configuration?
        #
        # @return [Boolean] True if the setting 'follow_links' is true, false
        #   otherwise
        def follow_links?()
            @settings.has_key? 'follow_links' and @settings['follow_links']
        end

        # Should pandocomatic convert a file with all matching templates or
        # only with the first matching template? Note. A 'use-template'
        # statement in a document will overrule this setting.
        #
        # @return [Boolean] True if the setting 'match-files' is 'all', false
        # otherwise.
        def match_all_templates?()
            @settings.has_key? 'match-files' and 'all' == @settings['match-files']
        end

        # Should pandocomatic convert a file with the first matching templates
        # or with all matching templates? Note. Multiple 'use-template'
        # statements in a document will overrule this setting.
        #
        # @return [Boolean] True if the setting 'match-files' is 'first', false
        # otherwise.
        def match_first_template?()
            @settings.has_key? 'match-files' and 'first' == @settings['match-files']
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
            File.join dir, "#{basename}.#{find_extension(dst, template_name, metadata)}"
        end

        # Set the destination file given this Confguration,
        # template, and metadata
        #
        # @param dst [String] path to a destination file
        # @param template_name [String] the name of the template used to
        #   convert to destination
        # @param metadata [PandocMetadata] the metadata in the source file
        def set_destination(dst, template_name, metadata)
            if dst.is_a? Tempfile
              return dst
            end

            dir = File.dirname dst

            # Use the output option when set.
            determine_output_in_pandoc = lambda do |pandoc|
                if pandoc.has_key? "output"
                    output = pandoc["output"]
                    if not output.start_with? "/"
                        # Put it relative to the current directory
                        output = File.join dir, output
                    end
                    output
                else
                    nil
                end
            end

            # Output options in pandoc property have precedence
            destination = determine_output_in_pandoc.call metadata.pandoc_options
            rename_script = metadata.pandoc_options["rename"]

            # Output option in template's pandoc property is next
            if destination.nil? and not template_name.nil? and not template_name.empty? then
                if @templates[template_name].has_pandoc?
                    pandoc = @templates[template_name].pandoc
                    destination = determine_output_in_pandoc.call pandoc
                    rename_script ||= pandoc["rename"]
                end
            end

            # Else fall back to taking the input file as output file with the
            # extension updated to the output format
            if destination.nil?
                destination = set_extension dst, template_name, metadata

                if not rename_script.nil? then
                    destination = rename_destination(rename_script, destination)
                end
            end

            # If there is a single file input without output specified, set
            # the output now that we know what the output filename is.
            @output = destination.delete_prefix "./" if not output?
            
            destination
        end

        # Find the extension of the destination file given this Confguration,
        # template, and metadata
        #
        # @param dst [String] path to a destination file
        # @param template_name [String] the name of the template used to
        #   convert to destination
        # @param metadata [PandocMetadata] the metadata in the source file
        #
        # @return [String] the extension to use for the destination file
        def find_extension(dst, template_name, metadata)
            extension = "html"

            # Pandoc supports enabling / disabling extensions
            # using +EXTENSION and -EXTENSION
            strip_extensions = lambda{|format| format.split(/[+-]/).first}
            use_extension = lambda do |pandoc|
                if pandoc.has_key? "use-extension"
                    pandoc["use-extension"]
                else
                    nil
                end
            end

            if template_name.nil? or template_name.empty? then
                ext = use_extension.call metadata.pandoc_options
                if not ext.nil?
                    extension = ext
                elsif metadata.pandoc_options.has_key? "to"
                    extension = strip_extensions.call(metadata.pandoc_options["to"])
                end
            else
                if @templates[template_name].has_pandoc?
                    pandoc = @templates[template_name].pandoc
                    ext = use_extension.call pandoc

                    if not ext.nil?
                        extension = ext
                    elsif pandoc.has_key? "to"
                        extension = strip_extensions.call(pandoc["to"])
                    end
                end
            end

            extension = DEFAULT_EXTENSION[extension] || extension
            extension
        end

        def is_markdown_file?(filename)
            if filename.nil? then
                false
            else
                ext = File.extname(filename).delete_prefix(".");
                "markdown" == DEFAULT_EXTENSION.key(ext)
            end
        end

        # Is there a template with template_name in this Configuration?
        #
        # @param template_name [String] a template's name
        #
        # @return [Boolean] True if there is a template with name equal to
        #   template_name in this Configuration
        def has_template?(template_name)
            @templates.has_key? template_name
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
            @convert_patterns.select do |template_name, globs|
                globs.any? {|glob| File.fnmatch glob, File.basename(src)}
            end.keys.first
        end

        # Determine the templates to use with this source document given this
        # Configuration.
        #
        # @param src [String] path to the source document
        # @return [Array[String]] the template's name to use
        def determine_templates(src)
            matches = @convert_patterns.select do |template_name, globs|
                globs.any? {|glob| File.fnmatch glob, File.basename(src)}
            end.keys
           
            if matches.empty?
               []
            elsif match_all_templates?
                matches
            else
                [matches.first]
            end
        end

        # Update the path to an executable processor or executor given this
        # Configuration
        #
        # @param path [String] path to the executable
        # @param src_dir [String] the source directory from which pandocomatic
        #   conversion process has been started
        # @param dst [String] the destination path
        # @param check_executable [Boolean = false] Should the executable be
        #   verified to be executable? Defaults to false.
        #
        # @return [String] the updated path.
        def update_path(path, src_dir, dst = "", check_executable = false, output = false)
            updated_path = path

            if is_local_path? path
                # refers to a local dir; strip the './' before appending it to
                # the source directory as to prevent /some/path/./to/path
                updated_path = path[2..-1]
            elsif is_absolute_path? path
                updated_path = path
            elsif is_root_relative_path? path
                updated_path = make_path_root_relative path, dst, @root_path
            else 
                if check_executable
                    updated_path = Configuration.which path
                end

                if updated_path.nil? or not check_executable then
                    # refers to data-dir
                    updated_path = File.join @data_dir, path
                end
            end

            updated_path
        end

        # Extend the current value with the parent value. Depending on the
        # value and type of the current and parent values, the extension
        # differs.
        #
        # For simple values, the current value takes precedence over the
        # parent value
        #
        # For Hash values, each parent value's property is extended as well
        #
        # For Arrays, the current overwrites and adds to parent value's items
        # unless the current value is a Hash with a 'remove' and 'add'
        # property. Then the 'add' items are added to the parent value and the
        # 'remove' items are removed from the parent value.
        #
        # @param current [Object] the current value
        # @param parent [Object] the parent value the current might extend
        # @return [Object] the extended value
        def self.extend_value(current, parent)
            if parent.nil?
                # If no parent value is specified, the current takes
                # precedence
                current
            else
                if current.nil?
                    # Current nil removes value of parent; follows YAML spec.
                    # Note. take care to actually remove this value from a
                    # Hash. (Like it is done in the next case)
                    nil
                else
                    if parent.is_a? Hash
                        if current.is_a? Hash
                            # Mixin current and parent values
                            parent.each_pair do |property, value|
                                if current.has_key? property
                                    extended_value = Configuration.extend_value(current[property], value)
                                    if extended_value.nil?
                                        current.delete property
                                    else
                                        current[property] = extended_value
                                    end
                                else
                                    current[property] = value
                                end
                            end
                        end
                        current
                    elsif parent.is_a? Array
                        if current.is_a? Hash
                            if current.has_key? 'remove'
                                to_remove = current['remove']

                                if to_remove.is_a? Array
                                    parent.delete_if {|v| current['remove'].include? v}
                                else
                                    parent.delete to_remove
                                end
                            end

                            if current.has_key? 'add'
                                to_add = current['add']
                                
                                if to_add.is_a? Array
                                    parent = current['add'].concat(parent).uniq
                                else
                                    parent.push(to_add).uniq
                                end
                            end

                            parent
                        elsif current.is_a? Array
                            # Just combine parent and current arrays, current
                            # values take precedence
                            current.concat(parent).uniq
                        else
                            # Unknown what to do, assuming current should take
                            # precedence
                            current
                        end
                    else
                        # Simple values: current replaces parent
                        current
                    end
                end
            end
        end

        def is_local_path?(path)
            if Gem.win_platform? then
                path.match("^\\.\\\\\.*$")
            else
                path.start_with? "./"
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
                if @templates.has_key? name
                    resolved_template.merge! Template.clone(@templates[name])
                else 
                    missing << name
                end
            end

            if not missing.empty?
                if template.internal?
                    warn "WARNING: Unable to find templates [#{missing.join(", ")}] while resolving internal template."
                else
                    warn "WARNING: Unable to find templates [#{missing.join(", ")}] while resolving the external template '#{template.name}' from configuration file '#{template.path}'."
                end
            end

            resolved_template.merge! template
            resolved_template
        end

        # Reset the template with name in this Configuration based on a new
        # template
        #
        # @param template [Template] the template to use to update the template in
        #   this Configuarion with
        def reset_template(template)
            name = template.name
            extended_template = extend_template template

            if @templates.has_key? name then
                @templates[name].merge! extended_template
            else
                @templates[name] = extended_template
            end

            if extended_template.has_glob? then
                @convert_patterns[name] = extended_template.glob
            end
        end

        # Cross-platform way of finding an executable in the $PATH.
        # 
        # which('ruby') #=> /usr/bin/ruby
        #
        # Taken from:
        # http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby#5471032
        def self.which(cmd)
            exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
            ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
                exts.each { |ext|
                    exe = File.join(path, "#{cmd}#{ext}")
                    return exe if File.executable?(exe) and
                        not File.directory?(exe)
                }
            end
            return nil
        end

        # Rename path by using rename script. If script fails somehow, warn
        # and return the original destination.
        #
        # @param rename_script [String] absolute path to script to run
        # @param dst [String] original destination to rename
        def rename_destination(rename_script, dst)
            script = update_path(rename_script, File.dirname(dst))

            command, *parameters = script.shellsplit # split on spaces unless it is preceded by a backslash

            if not File.exist? command
                command = Configuration.which(command)
                script = "#{command} #{parameters.join(' ')}"

                raise ProcessorError.new(:script_does_not_exist, nil, command) if command.nil?
            end

            raise ProcessorError.new(:script_is_not_executable, nil, command) unless File.executable? command

            begin
                renamed_dst = Processor.run(script, dst)
                if not renamed_dst.nil? and not renamed_dst.empty?
                    renamed_dst.strip
                else
                    raise StandardError,new("Running rename script '#{script}' on destination '#{dst}' did not result in a renamed destination.")
                    dst
                end
            rescue StandardError => e
                ProcessorError.new(:error_processing_script, e, [script, dst])
                dst
            end
        end
        
        def marshal_dump()
            [@data_dir, @settings, @templates, @convert_patterns]
        end

        def marshal_load(array)
            @data_dir, @settings, @templates, @convert_patterns = array
        end

        def is_absolute_path?(path)
            if Gem.win_platform? then
                path.match("^[a-zA-Z]:\\\\\.*$")
            else
                path.start_with? "/"
            end
        end

        def to_stdout?(options)
          not options.nil? and options[:stdout_given] and options[:stdout]
        end

        def is_root_relative_path?(path)
            path.start_with? ROOT_PATH_INDICATOR
        end

        def make_path_root_relative(path, dst, root)
            # Find how to get to the root directopry from dst directory.
            # Assumption is that dst is a subdirectory of root.
            dst_dir = File.dirname(File.absolute_path(dst))
            
            path.delete_prefix! ROOT_PATH_INDICATOR if is_root_relative_path? path

            if File.exist? root and File.realpath("#{dst_dir}").start_with?(File.realpath(root)) then
                rel_start = ""

                until File.identical?(File.realpath("#{dst_dir}/#{rel_start}"), File.realpath(root)) do
                    # invariant dst_dir/rel_start <= root
                    rel_start += "../" 
                end

                if rel_start.end_with? "/" and path.start_with? "/" then
                    "#{rel_start}#{path.delete_prefix("/")}"
                else
                    "#{rel_start}#{path}"
                end
            else
                # Because the destination is not in a subdirectory of root, a
                # relative path to that root cannot be created. Instead,
                # the path is assumed to be absolute relative to root
                root = root.delete_suffix "/" if root.end_with? "/"
                path = path.delete_prefix "/" if path.start_with? "/"

                "#{root}/#{path}"
            end
        end

        # Read a list of configuration files and create a
        # pandocomatic object that mixes templates from most generic to most
        # specific.
        def load_configuration_hierarchy(options, data_dirs)
          # Read and mixin templates from most generic config file to most
          # specific, thus in reverse order.
          @config_files = determine_config_files(options, data_dirs).reverse
          @config_files.each do |config_file|
            begin
              configure YAML.load_file(config_file), config_file
            rescue StandardError => e
              raise ConfigurationError.new(:unable_to_load_config_file, e, filename)
            end
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
            data_dir = Paru::Pandoc.info()[:data_dir]

            # If pandoc's data dir does not exist, however, fall back
            # to the current directory
            if File.exist? File.absolute_path(data_dir)
              data_dirs << data_dir
            else
              data_dirs << Dir.pwd
            end
          rescue Paru::Error => e
            # If pandoc cannot be run, continuing probably does not work out
            # anyway, so raise pandoc error
            raise PandocError.new(:error_running_pandoc, e, data_dir)
          rescue StandardError => e
            # Ignore error and use the current working directory as default working directory
            data_dirs << Dir.pwd
          end

          # check if data directories do exist and are readable
          data_dirs.uniq.map do |data_dir|
            path = File.absolute_path data_dir

            raise ConfigurationError.new(:data_dir_does_not_exist, nil, path) unless File.exist? path
            raise ConfigurationError.new(:data_dir_is_not_a_directory, nil, path) unless File.directory? path
            raise ConfigurationError.new(:data_dir_is_not_readable, nil, path) unless File.readable? path

            path
          end
        end

        def determine_data_dir(options)
          determine_data_dirs(config).first
        end

        def determine_root_path(options)
            if options[:root_path_given] then
                options[:root_path]
            elsif options[:output_given] then
                File.absolute_path(File.dirname options[:output])
            else
                File.absolute_path "."
            end
        end
    end
end
