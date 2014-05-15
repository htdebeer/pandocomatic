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
    
    def strict switch = true
      @options[:strict] = switch
    end

    def parse_raw switch = true
      @options[:parse_raw] = switch
    end

    def smart switch = true
      @options[:smart] = switch
    end

    def old_dashes switch = true
      @options[:old_dashes] = switch
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

    def normalize switch = true
      @options[:normalize] = switch
    end

    def preserve_tabs switch = true
      @options[:preserve_tabs] = switch
    end

    def tab_stop number
      if number.integer? and number >= 0
        @options[:tab_stop] = number
      else
        raise "Tab-stop expects and integer >= 0, got '#{number}' instead."
      end
    end

    def standalone switch = true
      @options[:standalone] = switch
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

    def no_wrap switch = true
      @options[:no_wrap] = switch
    end

    def columns number
      if number.integer? and number >= 0 then
        @options[:columns] = number
      else
        raise "Columns expects an integer >= 0, got '#{number}' instead."
      end
    end

    def toc switch = true
      @options[:toc] = switch
    end

    alias :table_of_contents :toc

    def toc_depth number
      if number.integer? and number >= 0 then
        @options[:columns] = number
      else
        raise "Toc-depth expects an integer >= 0, got '#{number}' instead."
      end
    end

    def no_highlight switch = true
      @options[:no_highlight] = switch
    end

    def highlight_style style
      if [:pygments, :kate, :monochrome, :espresso, :zenburn, :haddock, :tango].include? style.to_sym then
       @options[:highlight_style] = style
      else
        raise "Unknown highlighting style, '#{style}'"
      end 
    end

    def include_in_header filename
      if File.exists? filename then
        if File.readable? filename then
          if not @options[:include_in_header] then
            @options[:include_in_header] = []
          end
          @options[:include_in_header].push filename
        else
          raise "Header file '#{filename}' is not readable."
        end
      else
        raise "Header file '#{filename}' is not a file or does not exists."
      end
    end

    def include_after_body filename
      if File.exists? filename then
        if File.readable? filename then
          if not @options[:include_after_body] then
            @options[:include_after_body] = []
          end
          @options[:include_after_body].push filename
        else
          raise "After body file '#{filename}' is not readable."
        end
      else
        raise "After body file '#{filename}' is not a file or does not exists."
      end
    end

    def self_contained switch = true
      @options[:self_contained] = switch
    end

    def html_q_tags switch = true
      @options[:html_q_tags] = switch
    end

    def ascii switch = true
      @options[:ascii] = switch
    end

    def reference_links switch = true
      @options[:reference_links] = switch
    end

    def atx_headers switch = true
      @options[:atx_headers] = switch
    end

    def chapters switch = true
      @options[:chapters] = switch
    end

    def number_sections switch = true
      @options[:number_sections] = switch
    end

    def number_offset numberformat
      numbers = numberformat.split(',')
      if numbers.all? {|n| n.integer? and n >= 0} then
        @options[:number_offset] = numberformat
      else
        raise "'#{numberformat}' is not an acceptable number offset format"
      end
    end

    def no_tex_ligatures switch = true
      @options[:no_tex_ligatures] = switch
    end

    def listings switch = true
      @options[:listings] = switch
    end

    def incremental switch = true
      @options[:incremental] = switch
    end

    def slide_level number
      if number.integer? and number >= 0 then
        @options[:slide_level] = number
      else
        raise "Slide level should be a number >= 0, got '#{number}' instead"
      end
    end

    def section_divs switch = true
      @options[:section_divs] = switch
    end

    def email_obfuscation setting
      if [:none, :javascript, :references].include? setting then
        @options[:email_obfuscation] = setting
      else
        raise "Expected one of none, javascript or references as email obfuscation option, got '#{setting}' instead."
      end
    end

    def id_prefix prefix
      if not prefix.to_s.strip.empty? then
        @options[:id_prefix] = prefix.to_s.strip
      else
        raise "id prefix should be a non-empty string without whitespace, got '#{prefix}' instead."
      end
    end

    def title_prefix prefix
      if not prefix.to_s.empty? then
        @options[:title_prefix] = prefix
      else
        raise "title prefix should be an non-empty string."
      end
    end


    # Change filename to URL?
    def css filename
      if File.exists? filename then
        if File.readable? filename then
          if not @options[:css] then
            @options[:css] = []
          end
          @options[:css].push filename
        else
          raise "CSS file '#{filename}' is not readable."
        end
      else
        raise "CSS file '#{filename}' is not a file or does not exists."
      end
    end

    def reference_odt filename
      if File.exists? filename then
        if File.readable? filename then
          @options[:reference_odt].push filename
        else
          raise "Reference ODT file '#{filename}' is not readable."
        end
      else
        raise "Reference ODT file '#{filename}' is not a file or does not exists."
      end
    end

    def reference_docx filename
      if File.exists? filename then
        if File.readable? filename then
          @options[:reference_docx].push filename
        else
          raise "Reference docx file '#{filename}' is not readable."
        end
      else
        raise "Reference docx file '#{filename}' is not a file or does not exists."
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
