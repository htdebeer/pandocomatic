pandocomatic
============

Automating the use of pandoc

Pandocomatic automates the use of pandoc (<http://www.pandoc.org>). It can be
used to convert one file or a whole directory (tree).

This software is in alpha stage (version 0.0.13). Version 0.0.13 supports
pandoc version >= 1.18. For lower versions of pandoc, please use pandocomatic
version 0.0.9.

Licence: GPL3

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

When converting directories, only source files that are newer than the
desination files are being converted. Removing the destination files will
always cause regeneration.

# Configuration

Pandocomatic is configured by configuration files in the YAML format and are
named `pandocomatic.yaml`. Configuration files in a sub directory merge with
parent configurations, overwriting or adding to existing settings. A
configuration file consists of two (optional) parts: settings and templates

## Settings

    settings:
        data-dir: 'some/path/to/a/dir/with/stuff/to/use'
        recursive: true
        follow-links: false
        skip: ['*.swp']

You can set three different settings:

- in the first configuration file encountered, either through the option
  `--config filename.yaml` or the configuration file in the current directory,
  `data-dir` sets the directory where pandocomatic looks for template assets,
  such as pandoc template, preprocessors, and so on.

  In any next configuration file, this setting is ignored

  (*Question*: should this be the default behavior, or does it makes more sense
  to change the data-dir whenever it is specified?)

- `recursive` indicates if this directory and its children should be converted
  recursively, or if all subdirectories should be ignored during conversion.

- `follow-links` indicates if symbolic links in the source tree should be
  treated as the files and directories they point to, or if the links have to
  be recreated in the destination tree. If the latter (setting is `true`),
  only links that point inside the source tree are recreated in the
  destination tree.

- `skip`, an array indicating the glob patterns of all files and directories
  to skip on top of those defined in parent configuration files. Before the
  root configuration, skip is set to `['.*', 'pandocomatic.yaml']`: skip all
  hidden files and all pandocomatic configuration files.

## Templates

In the templates section, you can specify and refine templates. A template is
named and contains 4 items: 

- `glob`: an array of file patterns indicating to which files this template
  has to applied to.

- `preprocessors`, an array of paths to preprocessor scripts to be run in order
  before using pandoc for the conversion

- `pandoc`, a hash of pandoc options

- `postprocessors`, an array of paths to postprocessor scripts to be run in
  order after having used pandoc for the conversion.

The conversion process is:

    input -> preprocessor_0 -> ... -> preprocessor_n 
          -> pandoc 
          -> postprocessor_0 -> ... -> postprocessor_m
          -> output

For the preprocessors, postprocessors, and pandoc options taking a path as
value, there are three options:

- if a path starts with a '/', it is treated as an absolute path
- if a path starts with a '.', it is treated as an relative path in the same
  directory as the input file
- otherwise the path is treated as referring to a file in the `data-dir`
  specified in the settings.

For example, we could define the following templates to generate blog pages and
overview pages

    templates:
        blogpage:
            glob: ['*.markdown']
            preprocessors: []
            pandoc:
                from: 'markdown'
                to: 'html5'
                toc: true
                standalone: true
                template: 'templates/blogpost.html'
            postprocessors: []
        overview:
            glob: []
            preprocesors: ['preprocessors/gather_titles.sh']
            pandoc:
                from: 'markdown'
                to: 'html5'
                standalone: true
                template: 'templates/index.html'
            postprocessors: []

In this example, all markdown files are converted to blogposts, using the
template in `data-dir/templates/blogpost.html`. The overview pages are not
automatically used, but can be specified in a markdown file in a yaml block
using the `use-template` directive.
For example:

    ---
    title: Overview of all my blog posts
    pandocomatic:
        use-template: 'overview'
        pandoc:
            toc: true
    ...

    # This is my Blog

    Overview of all the pages:

In any markdown file, you can set more specific pandoc(omatic) options in a
yaml block by adding a `pandocomatic` setting, and adding to options set
earlier like in the example above
