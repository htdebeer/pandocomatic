Pandocomatic is configured by command line options and configuration files.

Automate the use of pandoc. Either converts a single file or a directory
tree. Configure the conversion process through configuration files.  Each
input file that is converted by pandocomatic is processed as follows:

input_file -> 
preprocessor(0) -> ... -> preprocessor(N) ->
pandoc -> 
postprocessor(0) -> ... -> postprocessor(M) -> 
output_file

The preprocessors and postprocessors used in the conversion process are
configured in pandocomatic templates. Besides processors, you can also
specify pandoc options to use to convert the input file. These templates are
specified in a configuration file. Templates can be used over and over, thus
automating the use of pandoc.

Configuration files are YAML files and can contain the
following properties:

- data-dir: PATH (see --data-dir option)

- settings:
- skip: [GLOB PATTERNS] files to not convert. By default
hidden files (starting with a ".") and
"pandocomatic.yaml" are skipped.
- recursive: BOOLEAN convert this directory recursively.
Default is TRUE
- follow_links: BOOLEAN follow symbolic links. Default is
TRUE

- templates:
- glob: [GLOB PATTERNS] files to convert using this
template.
- preprocessors: [SCRIPTS] paths to scripts to run before
converting with pandoc.
- postprocessors: [SCRIPTS] paths to scripts to run after
converting with pandoc.
- pandoc: PANDOC OPTIONS to use when converting with
pandoc.

Each file and directory that is converted can contain a
configuration YAML metadata block or YAML configuration file
respectively. In a file, the property 'use-template' tells
pandocomatic which template to use.
