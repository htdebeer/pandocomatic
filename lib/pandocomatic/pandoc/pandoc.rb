module Pandocomatic
  module Pandoc

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

      def output filename
        @options[:output] = filename
        self
      end

      def data_dir path = ''
        @options[:data_dir] = path
        self
      end
      
      def strict switch = true
        @options[:strict] = switch
        self
      end

      def parse_raw switch = true
        @options[:parse_raw] = switch
        self
      end

      def smart switch = true
        @options[:smart] = switch
        self
      end

      def old_dashes switch = true
        @options[:old_dashes] = switch
        self
      end

      def base_header_level number
        if number.integer? and number >= 1
          @options[:base_header_level] = number
        else
         raise "Base-header-level expects an integer >= 1, got '#{number} instead."
        end
        self
      end

      def indented_code_classes config
        @options[:indented_code_classes] = config
        self
      end

      def filter command
        if @options[:filter] then
          @options[:filter].push command
        else
          @options[:filter] = [command]
        end
        self
      end

      def normalize switch = true
        @options[:normalize] = switch
        self
      end

      def preserve_tabs switch = true
        @options[:preserve_tabs] = switch
        self
      end

      def tab_stop number
        if number.integer? and number >= 0
          @options[:tab_stop] = number
        else
          raise "Tab-stop expects and integer >= 0, got '#{number}' instead."
        end
        self
      end

      def standalone switch = true
        @options[:standalone] = switch
        self
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
        self
      end

      def metadata key, value = true
        if not @options[:metadata] then
          @options[:metadata] = Hash.new
        end
        @options[:metadata][key] = value
        self
      end

      def variable key, value = true
        if not @options[:variable] then
          @options[:variable] = Hash.new
        end
        @options[:variable][key] = value
        self
      end

      def no_wrap switch = true
        @options[:no_wrap] = switch
        self
      end

      def columns number
        if number.integer? and number >= 0 then
          @options[:columns] = number
        else
          raise "Columns expects an integer >= 0, got '#{number}' instead."
        end
        self
      end

      def toc switch = true
        @options[:toc] = switch
        self
      end

      alias :table_of_contents :toc

      def toc_depth number
        if number.integer? and number >= 0 then
          @options[:columns] = number
        else
          raise "Toc-depth expects an integer >= 0, got '#{number}' instead."
        end
        self
      end

      def no_highlight switch = true
        @options[:no_highlight] = switch
        self
      end

      def highlight_style style
        if [:pygments, :kate, :monochrome, :espresso, :zenburn, :haddock, :tango].include? style.to_sym then
         @options[:highlight_style] = style
        else
          raise "Unknown highlighting style, '#{style}'"
        end 
        self
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
        self
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
        self
      end

      def self_contained switch = true
        @options[:self_contained] = switch
        self
      end

      def html_q_tags switch = true
        @options[:html_q_tags] = switch
        self
      end

      def ascii switch = true
        @options[:ascii] = switch
        self
      end

      def reference_links switch = true
        @options[:reference_links] = switch
        self
      end

      def atx_headers switch = true
        @options[:atx_headers] = switch
        self
      end

      def chapters switch = true
        @options[:chapters] = switch
        self
      end

      def number_sections switch = true
        @options[:number_sections] = switch
        self
      end

      def number_offset numberformat
        numbers = numberformat.split(',')
        if numbers.all? {|n| n.integer? and n >= 0} then
          @options[:number_offset] = numberformat
        else
          raise "'#{numberformat}' is not an acceptable number offset format"
        end
        self
      end

      def no_tex_ligatures switch = true
        @options[:no_tex_ligatures] = switch
        self
      end

      def listings switch = true
        @options[:listings] = switch
        self
      end

      def incremental switch = true
        @options[:incremental] = switch
        self
      end

      def slide_level number
        if number.integer? and number >= 0 then
          @options[:slide_level] = number
        else
          raise "Slide level should be a number >= 0, got '#{number}' instead"
        end
        self
      end

      def section_divs switch = true
        @options[:section_divs] = switch
        self
      end

      EMAIL_OPTIONS = [:none, :javascript, :references]
      def email_obfuscation setting
        if EMAIL_OPTIONS.include? setting then
          @options[:email_obfuscation] = setting
        else
          raise "Expected one of #{EMAIL_OPTIONS.join(',')} as email obfuscation option, got '#{setting}' instead."
        end
        self
      end

      def id_prefix prefix
        if not prefix.to_s.strip.empty? then
          @options[:id_prefix] = prefix.to_s.strip
        else
          raise "id prefix should be a non-empty string without whitespace, got '#{prefix}' instead."
        end
        self
      end

      def title_prefix prefix
        if not prefix.to_s.empty? then
          @options[:title_prefix] = prefix
        else
          raise "title prefix should be an non-empty string."
        end
        self
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
        self
      end

      def reference_odt filename
        if File.exists? filename then
          if File.readable? filename then
            @options[:reference_odt] = filename
          else
            raise "Reference ODT file '#{filename}' is not readable."
          end
        else
          raise "Reference ODT file '#{filename}' is not a file or does not exists."
        end
        self
      end

      def reference_docx filename
        if File.exists? filename then
          if File.readable? filename then
            @options[:reference_docx] = filename
          else
            raise "Reference docx file '#{filename}' is not readable."
          end
        else
          raise "Reference docx file '#{filename}' is not a file or does not exists."
        end
        self
      end

      def epub_stylesheet filename
        if File.exists? filename then
          if File.readable? filename then
            @options[:epub_stylesheet] = filename
          else
            raise "EPUB stylesheet file '#{filename}' is not readable."
          end
        else
          raise "EPUB stylesheet file '#{filename}' is not a file or does not exists."
        end
        self
      end

      def epub_cover_image filename
        if File.exists? filename then
          if File.readable? filename then
            @options[:epub_cover_image] = filename
          else
            raise "EPUB cover image file '#{filename}' is not readable."
          end
        else
          raise "EPUB cover image file '#{filename}' is not a file or does not exists."
        end
        self
      end

      def epub_metadata filename
        if File.exists? filename then
          if File.readable? filename then
            @options[:epub_metadata] = filename
          else
            raise "EPUB metadata file '#{filename}' is not readable."
          end
        else
          raise "EPUB metadata file '#{filename}' is not a file or does not exists."
        end
        self
      end

      def epub_embed_font filename
        if File.exists? filename then
          if File.readable? filename then
            if not @options[:epub_embed_font] then
              @options[:epub_embed_font] = []
            end
            @options[:epub_embed_font].push filename
          else
            raise "EPUB embed font file '#{filename}' is not readable."
          end
        else
          raise "EPUB embed font file '#{filename}' is not a file or does not exists."
        end
        self
      end

      def epub_chapter_level number
        if number.integer? and number >= 0
          @options[:epub_chapter_level] = number
        else
          raise "EPUB chapter level should be an integer >= 0, got '#{number}' instead."
        end
        self
      end

      ENGINES = [:pdflatex, :lualatex, :xelatex]
      def latex_engine engine
        if ENGINES.include? engine.to_sym then
          @options[:latex_engine] = engine
        else
          raise "Expected one of #{ENGINES.join(',')} as value for option latex-engine, got '#{engine}' instead."
        end
        self
      end

      def bibliography filename
        if File.exists? filename then
          if File.readable? filename then
            @options[:bibliography] = filename
          else
            raise "Bibliography file '#{filename}' is not readable."
          end
        else
          raise "Bibliography file '#{filename}' is not a file or does not exists."
        end
        self
      end
      
      def csl filename
        if File.exists? filename then
          if File.readable? filename then
            @options[:csl] = filename
          else
            raise "csl file '#{filename}' is not readable."
          end
        else
          raise "csl file '#{filename}' is not a file or does not exists."
        end
        self
      end
      
      def citation_abbreviations filename
        if File.exists? filename then
          if File.readable? filename then
            @options[:citation_abbreviations] = filename
          else
            raise "citation abbreviations file '#{filename}' is not readable."
          end
        else
          raise "citation abbreviations file '#{filename}' is not a file or does not exists."
        end
        self
      end

      def latexmathml url = ''
        @options[:latexmathml] = url
        self
      end

      def mathml url = ''
        @options[:mathml] = url
        self
      end

      def jsmath url = ''
        @options[:jsmath] = url
        self
      end

      def gladtex switch = true
        @options[:gladtex] = switch
        self
      end

      def mimetex url = ''
        @options[:mimetex] = url
        self
      end

      def webtex url = ''
        @options[:webtex] = url
        self
      end


      def natbib switch = true
        @options[:natbib] = switch
        self
      end

      def biblatex switch = true
        @options[:biblatex] = switch
        self
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

      def convert input
        output = ''
        command = to_command
        IO.popen(command, 'r+') do |p|
          p << input
          p.close_write
          output << p.read
        end
        return output
      end
      alias << convert

    end

  end
end
