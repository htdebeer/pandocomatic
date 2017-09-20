#--
# Copyright 2014, 2015, 2016, 2017, Huub de Beer <Huub@heerdebeer.org>
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

    # The default configuration for pandocomatic is read from
    # default_configuration.yaml.
    DEFAULT_CONFIG = YAML.load_file File.join(__dir__, 'default_configuration.yaml')

    # Maps pandoc output formats to an extension.
    FORMAT_TO_EXT = {
        'native' => 'hs',
        'markdown' => 'md',
        'markdown_strict' => 'md',
        'markdown_phpextra' => 'md',
        'markdown_github' => 'md',
        'html5' => 'html',
        'docx' => 'docx',
        'latex' => 'tex',
        'context' => 'tex'
    }

    # A Configuration object models a pandocomatic configuration.
    class Configuration

        # Create a new Configuration instance based on the command-line
        # options, a data_dir, and a configuration file.
        def initialize options, data_dir, configuration_file
            @data_dir = data_dir

            load configuration_file
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

            # hidden files will always be skipped, as will pandocomatic
            # configuration files, unless explicitly set to not skip via the
            # "unskip" option

            @settings = {
                'skip' => ['.*', 'pandocomatic.yaml'],
                'recursive' => true,
                'follow-links' => false
            } 

            @templates = {}
            @convert_patterns = {}

            configure settings
        end

        # Update this configuration with a configuration file
        #
        # @param [String] filename path to the configuration file
        #
        # @return [Configuration] a new configuration
        def reconfigure(filename)
            begin
                settings = YAML.load_file filename
                new_config = Marshal.load(Marshal.dump(self))
                new_config.configure settings
                new_config
            rescue StandardError => e
                raise ConfigurationError.new(:unable_to_load_config_file, e, filename)
            end
        end

        # Configure pandocomatic based on a settings Hash
        #
        # @param settings [Hash] a settings Hash to mixin in this
        # Configuration.
        def configure(settings)
            reset_settings settings['settings'] if settings.has_key? 'settings'
            if settings.has_key? 'templates' then
                settings['templates'].each do |name, template|
                    full_template = {
                        'extends' => [],
                        'glob' => [],
                        'setup' => [],
                        'preprocessors' => [],
                        'metadata' => {},
                        'pandoc' => {},
                        'postprocessors' => [],
                        'cleanup' => []
                    }

                    reset_template name, full_template.merge(template)
                end
            end
        end

        # Convert this Configuration to a String
        #
        # @return [String]
        def to_s()
            marshal_dump
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
            @settings['recursive']
        end

        # Should pandocomatic follow symbolic links given this Configuration?
        #
        # @return [Boolean] True if the setting 'follow_links' is true, false
        #   otherwise
        def follow_links?()
            @settings['follow_links']
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
            if template_name.nil? or template_name.empty? then
                if metadata.has_pandocomatic? 
                    pandocomatic = metadata.pandocomatic
                    if pandocomatic.has_key? "pandoc"
                        pandoc = pandocomatic["pandoc"]

                        if pandoc.has_key? "to"
                            extension = pandoc["to"]
                        end
                    end
                end 
            else
                # TODO: what if there is no pandoc.to?
                if @templates[template_name].has_key? "pandoc"
                    pandoc = @templates[template_name]["pandoc"]
                    if pandoc.has_key? "to"
                        extension = pandoc["to"]
                    end
                end
            end

            extension = FORMAT_TO_EXT[extension] || extension
            return extension
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
        # @return [Hash] The template with template_name.
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

        # Update the path to an executable processor or executor given this
        # Configuration
        #
        # @param path [String] path to the executable
        # @param src_dir [String] the source directory from which pandocomatic
        #   conversion process has been started
        # @param check_executable [Booelan = false] Should the executable be
        #   verified to be executable? Defaults to false.
        #
        # @return [String] the updated path.
        def update_path(path, src_dir, check_executable = false)
            updated_path = path
            if path.start_with? './' 
                # refers to a local dir; strip the './' before appending it to
                # the source directory as to prevent /some/path/./to/path
                updated_path = File.join src_dir, path[2..-1]
            else
                if path.start_with? '/'
                    updated_path = path
                else 
                    if check_executable
                        updated_path = Configuration.which path
                    end

                    if updated_path.nil? or not updated_path.start_with? '/' then
                        # refers to data-dir
                        updated_path = File.join @data_dir, path
                    end
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

        # Deep copy a template
        #
        # @param template [Hash]  the template to clone
        # @return [Hash]
        def clone_template(template)
            Marshal.load(Marshal.dump(template))
        end

        # Merge two templates
        #
        # @param base_template [Hash] the base template
        # @param mixin_template [Hash] the template to mixin into the base template
        # @return [Hash] the merged templates
        def merge(base_template, mixin_template)
            if mixin_template['extends'] and mixin_template['extends'].is_a? String
                mixin_template['extends'] = [mixin_template['extends']]
            end

            fields = [
                'glob', 
                'metadata',
                'setup', 
                'preprocessors', 
                'pandoc', 
                'postprocessors', 
                'cleanup'
            ]
            
            fields.each do |field|
                parent = base_template[field]
                current = mixin_template[field]
                extended_value = Configuration.extend_value current, parent

                if extended_value.nil?
                    base_template.delete field
                else
                    base_template[field] = extended_value
                end
            end

            base_template
        end

        # Resolve the templates the templates extends and mixes them in, in
        # order of occurrence.
        #
        # @param template [Hash] the template to extend
        # @return [Hash] the resolved template
        def extend_template(template)
            resolved_template = {};
            if template.has_key? 'extends' and not template['extends'].empty?
                to_extend = template['extends']
                to_extend = [to_extend] if to_extend.is_a? String

                to_extend.each do |name|
                    if @templates.has_key? name
                        merge resolved_template, clone_template(@templates[name])
                    else 
                        warn "Cannot find template with name '#{parent_template_name}'. Skipping this template while extending: '#{template.to_s}'."
                    end
                end

                resolved_template
            end

            merge resolved_template, template
        end

        # Reset the template with name in this Configuration based on a new
        # template
        #
        # @param name [String] the name of the template in this Configuration
        # @param template [Hash] the template to use to update the template in
        #   this Configuarion with
        def reset_template(name, template)
            extended_template = extend_template template
            
            if @templates.has_key? name then
                merge @templates[name], extended_template
            else
                @templates[name] = extended_template
            end

            if extended_template.has_key? 'glob' then
                @convert_patterns[name] = extended_template['glob']
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
                    return exe if File.executable?(exe) &&
                        !File.directory?(exe)
                }
            end
            return nil
        end
        
        def marshal_dump()
            [@data_dir, @settings, @templates, @convert_patterns]
        end

        def marshal_load(array)
            @data_dir, @settings, @templates, @convert_patterns = array
        end

    end
end
