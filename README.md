pandocomatic
============

Automating the use of pandoc

Pandocomatic automates the use of pandoc (<http://www.pandoc.org>). It can be
used to convert one file or a whole directory (tree).

# Installation

    gem install pandocomatic

# Usage

    pandocomatic [--config pandocomatic.yaml] --output output input

## Options

-c, --config=<s>    Pandocomatic configuration file, default is
                  ./pandocomatic.yaml
-o, --output=<s>    output file or directory
-v, --version       Print version and exit
-h, --help          Show this message
