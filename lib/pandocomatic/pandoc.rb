module Pandocomatic

  require 'yaml'

  # Pandoc is a wrapper around the pandoc system. See
  # <http://johnmacfarlane.net/pandoc/README.html> for details about pandoc.
  # This file is basically a straightforward translation from command line
  # program to ruby class

  INPUT_FORMATS = [
    :docbook,
    :haddock,
    :html,
    :json,
    :latex,
    :markdown,
    :markdown_github,
    :markdown_mmd,
    :markdown_phpextra,
    :markdown_strict,
    :mediawiki,
    :native,
    :opml,
    :rst,
    :textile
  ]

  OUTPUT_FORMATS = [
    :asciidoc,
    :beamer,
    :context,
    :docbook,
    :docx,
    :dzslides,
    :epub,
    :epub3,
    :fb2,
    :html,
    :html5,
    :json,
    :latex,
    :man,
    :markdown,
    :markdown_github,
    :markdown_mmd,
    :markdown_phpextra,
    :markdown_strict,
    :mediawiki,
    :native,
    :odt,
    :opendocument,
    :opml,
    :org,
    :pdf,
    :plain,
    :revealjs,
    :rst,
    :rtf,
    :s5,
    :slideous,
    :slidy,
    :texinfo,
    :textile
  ]

  class Pandoc

    def initialize &block 
      @options = {
        :from => :markdown,
        :to => :html5
      }
      instance_eval(&block) if block_given?
    end

    # Each pandoc option gets a configuration method

    def from format
      if INPUT_FORMATS.include? format.to_sym then
        @options[:from] = format
      else
        raise "#{format} is not recognized as an output format."
      end
    end

    def to format
      if OUTPUT_FORMATS.include? format.to_sym then
        @options[:to] = format
      else
        raise "#{format} is not recognized as an input format."
      end
    end

    def data_dir path = ''
      @options[:data_dir] = path
    end
    
    def strict
      @options[:strict] = true
    end

    def parse_raw
      @options[:parse_raw] = true
    end

    def smart
      @options[:smart] = true
    end

    def old_dashes
      @options[:old_dashes] = true
    end

    def base_header_level number
      if number.integer? and number >= 1
        @options[:base_header_level] = number
      else
       raise "Base-header-level expects an integer >= 1, got '#{number} instead."
      end
    end

    def indented_code_classes config
      @options[:indented_code_classes] = config
    end

    def filter command
      if @options[:filter] then
        @options[:filter].push command
      else
        @options[:filter] = [command]
      end
    end

    def normalize
      @options[:normalize] = true
    end

    def preserve_tabs
      @options[:preserve_tabs]
    end

    def tab_stop number
      if number.integer? and number >= 0
        @options[:tab_stop] = number
      else
        raise "Tab-stop expects and integer >= 0, got '#{number}' instead."
      end
    end

    def standalone
      @options[:standalone] = true
    end

    def template filename
      if File.exists? filename then
        if File.readable? filename then
          @options[:template] = filename
        else
          raise "Template '#{filename}' is not readable."
        end
      else
        raise "Template '#{filename}' is not a file or does not exists."
      end
    end

    def metadata key, value = true
      if not @options[:metadata] then
        @options[:metadata] = Hash.new
      end
      @options[:metadata][key] = value
    end

    def variable key, value = true
      if not @options[:variable] then
        @options[:variable] = Hash.new
      end
      @options[:variable][key] = value
    end

    def no_wrap
      @options[:no_wrap] = true
    end

    def columns number
      if number.integer? and number >= 0 then
        @options[:columns] = number
      else
        raise "Columns expects an integer >= 0, got '#{number}' instead."
      end
    end

    def toc
      @options[:toc] = true
    end

    alias :table_of_contents :toc

    def toc_depth number
      if number.integer? and number >= 0 then
        @options[:columns] = number
      else
        raise "Toc-depth expects an integer >= 0, got '#{number}' instead."
      end
    end


    def to_option_string
      options_arr = []
      @options.each do |option, value|
        option_string = "--#{option.to_s.gsub '_', '-'}"
        if value.class == TrueClass then
          options_arr.push "#{option_string}"
        elsif value.class == FalseClass then
          # skip
        elsif value.class == Array then
          options_arr.push value.map {|val| "#{option_string} #{val.to_s}"}.join(' ')
        elsif value.class == Hash then
          value.each do |key, val| 
            if val.is_a? TrueClass then
              options_arr.push "#{option_string} #{key}"
            else
              options_arr.push "#{option_string} #{key}:'#{val}'"
            end
          end
        else
          options_arr.push "#{option_string} #{value.to_s}"
        end
      end
      return options_arr.join(' ')
    end

    def to_command
      return "pandoc #{to_option_string}"
    end

    def execute input
      output = 'test'
      command = to_command
      puts command
      IO.popen(command, 'r+') do |p|
        p << input
        p.close_write
        output << p.read
      end
      return output
    end

  end

end
