module Pandocomatic
  require "trollop"

  class CLI

    def self.parse args
      args = args.split if args.is_a? String
      
      # args should be an array of strings; what to do if it isn't?
      parser = CLI.new

      global_options = parser.parse_global_options args
      subcommand = args.shift
      options = parser.parse_options subcommand, args

      [global_options, subcommand, options]
    end

    private 

    def initialize
    end

    SUBCOMMANDS = [
      "run", 
      "install", 
      "uninstall", 
      "list", 
      "search",
      "help", 
      "version", 
    ]
    
    def parse_global_options args
      Trollop::options(args) do
        banner "Pandocomatic—Automatic the use of pandoc"
        opt :quiet, "Run quietly", :short => "-q"
        opt :dry_run, "Do a dry run", :short => "-d"
        stop_on SUBCOMMANDS
      end
    end

    def parse_options subcommand, args
      if SUBCOMMANDS.include? subcommand
        parse_method_name = "parse_#{subcommand}"
        parse_method = method parse_method_name if respond_to? parse_method_name
        parse_method.call args
      else
        # error
      end
    end

    def parse_run args
      Trollop::options(args) do 
        opt :config, "Configuration file", :short => "-c"
      end
    end

    def parse_version args
      Trollop::options(args) do
        # no options allowed
      end
    end

    def parse_help args
      topic = :default
      Trollop::options(args) do
        stop_on SUBCOMMANDS
        # no options allowed
      end
      topic = args.shift
      {:topic => topic}
    end

  end
end

