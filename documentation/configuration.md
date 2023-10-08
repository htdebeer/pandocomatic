Pandocomatic is configured by a combination of command-line options and
configuration files.

Each input file that is converted by pandocomatic is processed as follows:
    

    START
        ⇢   setup₀ 
            … 
            setupᵣ
    input_file  →   preprocessor₀ 
                    … 
                    preprocessorₙ 

                →   pandoc

                →   postprocessor₀ 
                    … 
    output_file ←   postprocessorₘ
        ⇢   cleanup₀ 
            … 
            cleanupₚ
    END

You specify the cleanup script, the preprocessors scripts, postprocessors
scripts, and cleanup scritps to use in the conversion process in pandocomatic
templates. Besides processors, you can also specify pandoc options to use to
convert an input file. You specify these templates in a configuration file.
Templates can be used over and over, thus automating the use of pandoc.

Write your configuration files in [YAML](http://www.yaml.org/). These
configuration files contain the following properties:

-   **settings**:
    -   **skip**: An array of
        [glob](https://en.wikipedia.org/wiki/Glob_(programming)) patterns of
        files and directories that pandocomatic will not touch or convert. By
        default, pandocomatic skips hidden files, i.e. files with a name
        starting with a ".", and the default pandocomatic configuration file
        "pandocomatic.yaml".
    -   **recursive**: A boolean property instructing pandocomatic to convert
        the subdirectories of a directory as well. By default this setting is
        `true`.
    -   **follow_links**: A boolean property telling pandocomatic to follow
        symbolic links. By default, this option is `true`. Note, pandocomatic
        will *never* visit links that point outside the input source's
        directory tree.
-   **templates**:
    -   **glob**: An array of glob patterns of filenames that pandocomatic
        converts automatically using this template.
    -   **setup**: An array of scripts to run before the preprocessors start
        working on the input. These startup scripts typically setup the
        environment wherein the conversion takes place. For example, creating
        a temporary working directory, copying static assets like images, and
        so on.
    -   **preprocessors**: An array of scripts to run on an input file before
        converting the output of those scripts with pandoc.
    -   **metadata**: 
    -   **pandoc**: Pandoc options to use when converting an input file using
        this template.
    -   **postprocessors**: An array of scripts to run on the result of the
        pandoc conversion. The output of these scripts will be written to the
        output file.
    -   **cleanup**: An array of scripts that run after the conversion process
        and postprocessors have finished. These cleanup scripts typically
        clean up the environment.

Each file and directory that is converted can contain a configuration YAML
metadata block or a YAML configuration file respectively. In a file, the
property *use-template* tells pandocomatic which template to use to convert
that file.

See the next two chapters for more extensive examples of using and configuring
pandocomatic.
