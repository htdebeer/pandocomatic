module Pandocomatic
  require "optparse"

  SUBCOMMANDS = {
    "_none" => OptionParser.new do |opts|
    end,
    "help" => OptionParser.new do |opts|
      opts.banner = "Help. Usage: pandocomatic help [subcommand]"
    end
  }

  ##
  # PandocomaticCLI describes and executes the command-line interface to pandocomatic
  #
  class PandocomaticCLI 
    def initialize
      @options= {}
    end
  end
end
