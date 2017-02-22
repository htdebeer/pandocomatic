You run pandocomatic like:

~~~{.bash}
pandocomatic --dry-run --output index.html --input my_doc.md
~~~

Pandocomatic takes a number of arguments which at the least should include the
input and output files or directories. The general form of a pandocomatic
invocation is:

    pandocomatic options [INPUT]

The required and optional arguments are discussed next, followed by some
examples. See next chapter for a more in-depth coverage of the configuration
of pandocomatic.

## Required arguments

Two arguments are required when running pandocomatic: the input file or
directory and the output file or directory:

-   `-i PATH, --input PATH`: Convert `PATH`. If this option is not given, `INPUT` is converted. `INPUT`
    and `--input` or `-i` cannot be used together.
-   `-o PATH, --output PATH`: Create converted files and directories in `PATH`.
  
    Although inadvisable, you can specify the output file in the metadata of a
    pandoc markdown input file. In that case, you can omit the output
    argument.

The input and output should both be files or both be directories.

## Optional arguments

Besides the two required arguments, there are two arguments to configure
pandocomatic, three arguments to change how pandocomatic operates, and the
conventional help and version arguments.

### Arguments to configure pandocomatic

-   `-d DIR, --data-dir DIR`: Configure pandocomatic to use `DIR` as its data directory. The default
    data directory is pandoc's data directory. (Run `pandoc --version` to find
    pandoc's data directory on your system.)
-   `-c FILE, --config FILE`: Configure pandocomatic to use `FILE` as its configuration file to use
    during the conversion process. Default is `DATA_DIR/pandocomatic.yaml`.

### Arguments to change how pandocomatic operates

-   `-m, --modified-only`: Only convert files that have been modified since the last time
    pandocomatic has been run. Or, more precisely, only those source files
    that have been updated at later time than the corresponding destination
    files will be converted, copied, or linked.  Default is `false`.
-   `-q, --quiet`: By default pandocomatic is quite verbose when you convert a directory. It
    tells you about the number of commands to execute. When executing these
    commands, pandocomatic tells you what it is doing, and how many commands
    still have to be executed. Finally, when pandocomatic is finished, it
    tells you how long it took to perform the conversion.
  
    If you do not like this verbose behavior, use the `--quiet` or `-q`
    argument to run pandocomatic quietly. Default is `false`.
-   `-y, --dry-run`: Inspect the files and directories to convert, but do not actually run the
    conversion. Default is `false`.

### Conventional arguments: help and version

-   `-v, --version`: Show the version. If this option is used, all other options are ignored.
-   `-h, --help`: Show a short help message. If this options is used, all other options
    except `--version` or `-v` are ignored.
