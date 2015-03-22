module Pandocomatic

    require 'yaml'
    require 'paru/pandoc'

    DEFAULT_CONFIG = YAML.load_file File.join(__dir__, 'default_configuration.yaml')

    FORMAT_TO_EXT = {
        'native' => 'hs',
        'markdown_strict' => 'markdown',
        'markdown_phpextra' => 'markdown',
        'markdown_github' => 'markdown',
        'html5' => 'html',
        'docx' => 'docx',
        'latex' => 'tex'
    }

    class Configuration

        def initialize filename
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
                else
                    @data_dir = File.join Dir.home, '.pandocomatic'
                end
            rescue Exception => e
                raise "Unable to load configuration file #{settings}: #{e.message}"
            end

            @settings = {'skip' => ['.*', 'pandocomatic.yaml']} # hidden files will always be skipped, as will pandocomatic configuration files
            @templates = {}
            @convert_patterns = {}
            configure settings
        end

        def reconfigure filename
            begin
                settings = YAML.load_file filename
                new_config = Marshal.load(Marshal.dump(self))
                new_config.configure settings
                new_config
            rescue Exception => e
                raise "Unable to load configuration file #{filename}: #{e.message}"
            end
        end

        def configure settings
            reset_settings settings['settings'] if settings.has_key? 'settings'
            if settings.has_key? 'templates' then
                settings['templates'].each do |name, template|
                    full_template = {
                        'glob' => [],
                        'preprocessors' => [],
                        'pandoc' => {},
                        'postprocessors' => []
                    }

                    reset_template name, full_template.merge(template)
                end
            end
        end

        def marshal_dump
            [@data_dir, @settings, @templates, @convert_patterns]
        end

        def marshal_load array
            @data_dir, @settings, @templates, @convert_patterns = array
        end
    
        def skip? src
            if @settings.has_key? 'skip' then
                @settings['skip'].any? {|glob| File.fnmatch glob, File.basename(src)}
            else
                false
            end
        end

        def convert? src
            @convert_patterns.values.flatten.any? {|glob| File.fnmatch glob, File.basename(src)}
        end

        def recursive?
            @settings['recursive']
        end

        def follow_links?
            @settings['follow_links']
        end

        def set_extension dst
            dir = File.dirname dst
            ext = File.extname dst
            basename = File.basename dst, ext
            File.join dir, "#{basename}.#{find_extension dst}"
        end

        def find_extension dst
            template = determine_template dst
            if template.nil? then
                extension = 'html'
            else
                to = @templates[template]['pandoc']['to']
                extension = FORMAT_TO_EXT[to] || to
            end
        end

        def get_template template_name
            @templates[template_name]
        end

        def determine_template src
            @convert_patterns.select do |template_name, globs|
                globs.any? {|glob| File.fnmatch glob, File.basename(src)}
            end.keys.first
        end

        def update_path path, src_dir
            if path.start_with? './' 
                # refers to a local (to file) dir
                File.join src_dir, path
            elsif path.start_with? '/' then
                path
            else
                # refers to data-dir
                File.join @data_dir, path
            end
        end

        private 
        
        def reset_settings settings
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

        def reset_template name, template
            if @templates.has_key? name then
                @templates[name].merge!(template) do |setting, oldval, newval|
                    case setting
                    when 'preprocessors', 'postprocessors', 'glob'
                        oldval.concat(newval).uniq
                    when 'pandoc'
                        oldval.merge newval
                    else
                        newval
                    end
                end
            else
                @templates[name] = template
            end
            if template.has_key? 'glob' then
                @convert_patterns[name] = template['glob']
            end
        end

    end

end
