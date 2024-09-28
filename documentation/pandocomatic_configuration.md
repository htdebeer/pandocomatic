## Pandocomatic configuration {#pandocomatic-configuration}

Pandocomatic can be configured by means of *pandocomatic configuration files*,
which are YAML files. For example, the following YAML code is a valid
*pandocomatic configuration file*:

```{.yaml}
::paru::insert ../example/manual/example_configuration_file.yaml
```

By default, pandocomatic looks for the configuration files in both the
**pandoc** data directory and the *pandocomatic data directory*; by
convention, pandocomatic expects these files to be named `pandocomatic.yaml`. 

On top of that, you can tell pandocomatic to use a specific configuration file
via the command-line option `--config`. For example, if you want to use a
configuration file `my-config.yaml`, invoke pandocomatic as follows:

```{.bash}
pandocomatic --config my-config.yaml some-file-to-convert.md
```

A *pandocomatic configuration file* contains two properties:

1. global `settings`
2. external `templates`

I discuss these two properties next. Before I do, however, I describe
pandocomatic's configuration hierarchy. For more in-depth information about
pandocomatic templates, please see the [Chapter on pandocomatic
templates](#pandocomatic-templates). 

### Pandocomatic's configuration hierarchy

If you're using pandocomatic a lot, you might have collected many useful
templates that you often use. Instead of having to copy them to a new
configuration file each time you start a new project, you can put them in a
configuration file in one of pandocomatic's data directories. Pandocomatic
will construct a configuration hierarchy based on these more global
configuration files as follows:

1. This configuration hierarchy starts with the [default
   configuration](https://github.com/htdebeer/pandocomatic/blob/master/lib/pandocomatic/default_configuration.yaml)
   that's part of pandocomatic. This is the base configuration that's always
   there.
2. Then pandocomatic mixes in the configuration files named
   `pandocomatic.yaml` found in the data directories in the following order:

   1. The configuration file in the *pandocomatic data directory* specified on
      the command line with option "--data-dir" or "-d".  
   2. The configuration file in the *pandoc data directory*, if it exists.
      Otherwise, as a fall-back, the current working directory is used. Note, a
      missing pandoc data directory is likely a sign of a broken pandoc
      installation.
3. Finally, the configuration file given on the command line with the
   "--config" or "-c" option is mixed in.

Pandodomatic always constructs the configuration hierarchy in this exact
order, skipping any configuration that's missing.  Thus, the default
configuration is extended first by the configuration from pandocomatic's data
directory, then by the configuration from pandoc's data directory, and finally
by the configuration specified with the `--config` option.

If you run pandocomatic with command-line option `--verbose`, it should print
this configuration hierarchy.

### Settings

You can configure five optional global settings:

1. `data-dir`
2. `match-files`
3. `extract-metadata-from`
4. `skip`
5. `recursive`
6. `follow-links`

The latter three are used only when converting a whole directory tree with
pandocomatic. These are discussed in the next sub section.

The first setting, `data-dir` (String), tells pandocomatic where its
*data directory* is. You can also specify the *pandocomatic data directory*
via the command-line option `--data-dir`. For example, if you want to use
`~/my-data-dir` as the *pandocomatic data directory*, invoke pandocomatic as
follows:

```{.bash}
pandocomatic --data-dir ~/my-data-dir some-file-to-convert.md
```

If no *pandocomatic data directory* is specified whatsoever, pandocomatic
defaults to pandoc's data directory.

Any directory can be used as a *pandocomatic data directory*, there are no
conventions or requirements for this directory other than being a directory.
However, it is recommended to create a meaningful sub directory structure. For
example, a sub directory for processors, filters, CSL files, and pandoc
templates makes it easier to manage and point to these assets.

The setting `match-files` controls how pandocomatic selects the template to
use to convert a file. Possible values for `match-files` are `first` and
`all`. Pandocomatic matches a file to a template as follows:

1.  If the file has one or more `use-template` statements in the
    *pandocomatic* metadata, it will use these specified templates.
2.  However, if no such templates are specified in the file, pandocomatic
    tries to find *global* templates as follows:

    a.  If the setting `match-files` has value `all`, all templates with a
        glob pattern that matches the input filename are used to convert that
        input file. For example, you can specify a template `www` to convert
        `*.md` files to HTML and a template `pdf` to convert `*.md` to PDF. In
        this case, a markdown file will be converted to both HTML and PDF. For
        example, you could use this to generate a website with a print PDF page
        for each web page.  
        
    b.  If the setting `match-files` has value `first`,
        the first template with a glob pattern that matches the input file is used
        to convert the file.

        This is the default.

The third setting, `extract-metadata-from` controls from which files
pandocomatic tries to extract pandoc metadata YAML blocks. In these metadata
blocks, you can set metadata specific to the document in the file. This
metadata can include instructions for pandocomatic, like selecting a template
to use, or to setup an internal pandocomatic template.

Pandocomatic always tries to extract metadata YAML blocks from markdown files.
If pandocomatic doesn't know if the file it is processing is a markdown file,
it falls back to pandoc's default behavior in recognizing markdown files.
However, if you give your markdown files a file extension than isn't
recognized by pandocomatic or pandoc as a markdown file, e.g., ".pandoc", use property
`extract-metadata-from` to tell pandocomatic to extract metadata from
those files.

Property `extract-metadata-from` takes a list of glob patterns. For example,
to extract metadata from ".pandoc" files, use:

```{.yaml}
settings:
  # ...
  extract-metadata-from: ['*.pandoc']
  # ...
```

Note that the `extract-metadata-from` property cannot be used to stop
pandocomatic from extracting metadata from markdown files. 

#### Configuring converting a directory tree {#global-settings}

You can convert a directory tree by invoking pandocomatic with a single
directory as the input rather than one or more files. Of course, once you
start converting directories, more fine-grained control over what files to
convert than "convert all files" is useful. There are four settings you can
use to control which files to convert. Three of them are global settings, the
other one is the `glob` property of an *external pandocomatic template*. The
`glob` property is discussed later.

The three global settings to control which files to convert are:

1. `recursive` (Boolean), which tells pandocomatic to convert sub directories
   or not.  This setting defaults to `true`.
2. `follow-links` (Boolean), which tells pandocomatic to treat symbolic links
   as files and directories to convert or not. This setting defaults to
   `false`.
3. `skip` (Array of glob patterns), which tells pandocomatic which files not
   to convert at all. This setting defaults to `['.*', 'pandocomatic.yaml']`:
   ignore all hidden files (starting with a period) and also ignore default
   *pandocomatic configuration files*.

#### Default configuration

Pandocomatic's default configuration file is defined in the file
[`lib/pandocomatic/default_configuration.yaml`](https://github.com/htdebeer/pandocomatic/blob/master/lib/pandocomatic/default_configuration.yaml).
This default configuration is used when

- no configuration is specified via the command-line option `--config`, and
- no default configuration file (`pandocomatic.yaml`) can be found in the
  *pandocomatic data directory*.

When converting a directory tree, each time pandocomatic enters a (sub)
directory, it also looks for a default configuration file to *update* the
current settings. In other words, you can have pandocomatic behave differently
in a sub directory than the current directory by putting a `pandocomatic.yaml`
file in that sub directory that changes the global settings or *external
pandocomatic templates*.

### Templates

Besides the global `settings` property, a *pandocomatic configuration file* can
also contain a `templates` property. In the `templates` property you define the
*external pandocomatic templates* you want to use when converting files with
pandocomatic. Pandocomatic templates are discussed in detail in the [Chapter
on pandocomatic templates](#pandocomatic-templates). The `glob` property of
*external pandocomatic templates* is related to configuring pandocomatic when
converting a directory. It
tells pandocomatic which files in a directory are to be converted with a template.

If you look at the example *pandocomatic configuration file* at the start of
this chapter, you see that the `webpage` template is configured with property `glob:
['*.md']`. This tells pandocomatic to apply the template `webpage` to all
markdown files with extension `.md`. In other words, given a directory with
the following files:

```
directory/
+ sub directory/
| + index.md
- index.md
- image.png 
```

Running pandocomatic with the example *pandocomatic configuration file* will
result in the following result"

```
directory/
+ sub directory/
| + index.html
- index.html
- image.png 
```

That is, all `.md` files are converted to HTML and all other files are copied,
recursively.
