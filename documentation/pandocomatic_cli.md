## Pandocomatic command-line interface {#pandocomatic-cli}

Pandocomatic takes a number of arguments which at the least should include the
input file or directory. The general form of a pandocomatic invocation is:

```{.bash}
pandocomatic options [INPUT]
```

### General arguments: help and version

`-v, --version`

:   Show the version. If this option is used, all other options are ignored.

`-h, --help`

:   Show a short help message. If this option is used, all other options
    except `--version` or `-v` are ignored.

### Input/output arguments

`-i PATH, --input PATH`

:   Convert `PATH`. If this option is not given, `INPUT` is converted. `INPUT`
    and `--input` or `-i` cannot be used together.

`-o PATH, --output PATH`

:   Create converted files and directories in `PATH`.
  
    You can specify the output file in the metadata of a pandoc markdown input
    file. In that case, you can omit the output argument. Furthermore, if no
    output file is specified whatsoever, pandocomatic defaults to output to
    HTML by replacing the extension of the input file with `html`.

The input and output should both be files or both be directories. Pandocomatic
will complain if the input and output types do not match.

### Arguments to configure pandocomatic

`-d DIR, --data-dir DIR`

:   Configure pandocomatic to use `DIR` as its data directory. The default
    data directory is pandoc's data directory. (Run `pandoc --version` to find
    pandoc's data directory on your system.)

`-c FILE, --config FILE`

:   Configure pandocomatic to use `FILE` as its configuration file 
    during the conversion process. Default is `DATA_DIR/pandocomatic.yaml`.

### Arguments to change how pandocomatic operates

`-m, --modified-only`

:   Only convert files that have been modified since the last time
    pandocomatic has been run. Or, more precisely, only those source files
    that have been updated at a later time than the corresponding destination
    files will be converted, copied, or linked.  Default is `false`.

`-q, --quiet`

:   By default pandocomatic is verbose when you convert a directory. It
    tells you about the number of commands to execute. When executing these
    commands, pandocomatic tells you what it is doing, and how many commands
    still have to be executed. Finally, when pandocomatic is finished, it
    tells you how long it took to perform the conversion.
  
    If you do not like this verbose behavior, use the `--quiet` or `-q`
    argument to run pandocomatic quietly. Default is `false`.

`-y, --dry-run`

:   Inspect the files and directories to convert, but do not actually run the
    conversion. Default is `false`.

`-b, --debug`

:   Run pandocomatic in debug mode. At the moment this means that all pandoc
    invocations are printed as well.

### Status codes

When pandocomatic runs into a problem, it will return with status codes `1266`
or `1267`. The former is returned if something goes wrong before any conversion
is started and the latter when something goes wrong during the conversion
process.
