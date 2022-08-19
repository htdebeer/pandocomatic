Pandocomatic is configured by command line options and configuration files.
Each input file that is converted by pandocomatic is processed as follows:

    input_file -> 
      preprocessor(0) -> ... -> preprocessor(N) ->
        pandoc -> 
          postprocessor(0) -> ... -> postprocessor(M) -> 
            output_file

The preprocessors and postprocessors used in the conversion process are
configured in pandocomatic templates. Besides processors, you can also specify
pandoc options to use to convert an input file. These templates are specified
in a configuration file. Templates can be used over and over, thus automating
the use of pandoc.

Configuration files are [YAML](http://www.yaml.org/) files and can contain the
following properties:

-   **settings**:
    -   **skip**: An array of glob patterns of files and directories to not
        convert. By default, hidden files (starting with a ".") and
        "pandocomatic.yaml" are skipped.
    -   **recursive**: A boolean telling pandocomatic to convert the
        subdirectories of a directory as well. By default this setting is
        `true`.
    -   **follow_links**: A boolean telling pandocomatic to follow symbolic
        links. By default, this option is `true`. Note, links that point outside the input
        source's directory tree will not be visited.
-   **templates**:
    -   **glob**: An array of glob patterns of files to convert using this
        template.
    -   **preprocessors**: An array of scripts to run on an input file before
        converting the output of those scripts with pandoc.
    -   **pandoc**: Pandoc options to use when converting an input file using
        this template.
    -   **postprocessors**: An array of scripts to run on the result of the
        pandoc conversion. The output of these scripts will be written to the
        output file.

Each file and directory that is converted can contain a configuration YAML
metadata block or a YAML configuration file respectively. In a file, the
property *use-template* tells pandocomatic which template to use to convert
that file.

See the next two chapters for more extensive examples of using and configuring
pandocomatic.
