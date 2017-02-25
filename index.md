---
author: Huub de Beer
keywords:
- pandoc
- ruby
- paru
- pandocomatic
- static site generator
subtitle: Automating the use of pandoc
title: Pandocomatic
---

Introduction
============

Pandocomatic is a tool to automate using [pandoc](http://pandoc.org/).
With pandocomatic you can express common patterns of using pandoc for
generating your documents. Applied to a directory, pandocomatic can act
as a static site generator. For example, this manual and the website it
is put on are generated using pandocomatic!

Why pandocomatic?
-----------------

I use [pandoc](http://pandoc.org/) a lot. I use it to write all my
papers, notes, reports, outlines, summaries, and books. Time and again I
was invoking pandoc like:

``` {.bash}
pandoc --from markdown \
  --to html5 \
  --standalone \
  --csl apa.csl \
  --bibliography my-bib.bib \
  --mathjax \
  --output result.html \
  source.md
```

Sure, when I write about history, the csl file and bibliography changes.
And I do not need the `--mathjax` option like I do when I am writing
about mathematics education. Still, all these invocations are quite
similar.

I already wrote the program *do-pandoc.rb* as part of a
[Ruby](https://www.ruby-lang.org/en/) wrapper around pandoc,
[paru](https://heerdebeer.org/Software/markdown/paru/). Using
*do-pandoc.rb* I can specify the options to pandoc as pandoc metadata in
the source file itself. The above pandoc invocation then becomes:

``` {.bash}
do-pandoc.rb source.md
```

It saves me from typing out the whole pandoc invocation each time I run
pandoc on a source file. However, I have still to setup the same options
to use in each document that I am writing, even though these options do
not differ that much from document to document.

*Pandocomatic* is a tool to re-use these common configurations by
specifying a so-called *pandocomatic template* in a
[YAML](http://yaml.org/) configuration file. For example, by placing the
following file, `pandocomatic.yaml` in pandoc's data directory:

``` {.yaml}
template:
  education-research:
    preprocessors: []
    pandoc:
      from: markdown
      to: html5
      standalone: true
      cls: 'apa.csl'
      toc: true
      bibliography: /path/to/bibliography.bib
      mathjax: true
    postprocessors: []
```

I now can create a new document that uses that configuration by using
the following metadata in my source file, `on_teaching_maths.md`:

``` {.pandoc}
---
title: On teaching mathematics
author: Huub de Beer
pandocomatic:
  use-template: education-research
  pandoc:
    output: on_teaching_mathematics.html
...

and here follows the contents of my new paper...
```

To convert this file to `on_teaching_mathematics.html` I now run
pandocomatic as follows:

``` {.bash}
pandocomatic -i on_teaching_maths.md
```

With just two lines of pandoc metadata, I can tell pandocomatic what
template to use when converting a file. Adding file-specific pandoc
options to the conversion process is as easy as adding a `pandoc`
property with those options to the `pandocomatic` metadata property in
the source file.

Once I had written a number of related documents this way, it was a
small step to enable pandocomatic to convert directories as well as
files. Just like that, pandocomatic can be used as a *static site
generator*!

But more about that later. First, the installation of pandocomatic is
described, followed by its license. After that, in the next chapters,
using pandocomatic and configuring pandocomatic are described in detail.
The last two chapters of this manual describe two typical use cases for
pandocomatic: i) automating setting up and running pandoc for a series
of related papers and ii) using pandocomatic as a static site generator.

Licence
-------

Pandocomatic is [free
sofware](https://www.gnu.org/philosophy/free-sw.en.html); pandocomatic
is released under the
[GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html). You find
pandocomatic's source code on
[github](https://github.com/htdebeer/pandocomatic).

Installation
------------

Pandocomatic is installed through [RubyGems](https://rubygems.org/) as
follows:

``` {.bash}
gem install pandocomatic
```

You can also download the latest gem
[pandocomatic-0.1.0](https://github.com/htdebeer/pandocomatic/blob/master/releases/pandocomatic-0.1.0.gem)
from github and install it as follows:

``` {.bash}
cd /directory/you/downloaded/the/gem/to
gem install pandocomatic-0.1.0.gem
```

Pandocomatic builds on
[paru](https://heerdebeer.org/Software/markdown/paru/), a Ruby wrapper
around pandoc, and [pandoc](http://pandoc.org/) itself, of course.

Using pandocomatic
==================

You run pandocomatic like:

``` {.bash}
pandocomatic --dry-run --output index.html --input my_doc.md
```

Pandocomatic takes a number of arguments which at the least should
include the input and output files or directories. The general form of a
pandocomatic invocation is:

    pandocomatic options [INPUT]

The required and optional arguments are discussed next, followed by some
examples. See next chapter for a more in-depth coverage of the
configuration of pandocomatic.

Required arguments
------------------

Two arguments are required when running pandocomatic: the input file or
directory and the output file or directory:

`-i PATH, --input PATH`

:   Convert `PATH`. If this option is not given, `INPUT` is converted.
    `INPUT` and `--input` or `-i` cannot be used together.

`-o PATH, --output PATH`

:   Create converted files and directories in `PATH`.

    Although inadvisable, you can specify the output file in the
    metadata of a pandoc markdown input file. In that case, you can omit
    the output argument.

The input and output should both be files or both be directories.

Optional arguments
------------------

Besides the two required arguments, there are two arguments to configure
pandocomatic, three arguments to change how pandocomatic operates, and
the conventional help and version arguments.

### Arguments to configure pandocomatic

`-d DIR, --data-dir DIR`

:   Configure pandocomatic to use `DIR` as its data directory. The
    default data directory is pandoc's data directory. (Run
    `pandoc --version` to find pandoc's data directory on your system.)

`-c FILE, --config FILE`

:   Configure pandocomatic to use `FILE` as its configuration file to
    use during the conversion process. Default is
    `DATA_DIR/pandocomatic.yaml`.

### Arguments to change how pandocomatic operates

`-m, --modified-only`

:   Only convert files that have been modified since the last time
    pandocomatic has been run. Or, more precisely, only those source
    files that have been updated at later time than the corresponding
    destination files will be converted, copied, or linked. Default is
    `false`.

`-q, --quiet`

:   By default pandocomatic is quite verbose when you convert
    a directory. It tells you about the number of commands to execute.
    When executing these commands, pandocomatic tells you what it is
    doing, and how many commands still have to be executed. Finally,
    when pandocomatic is finished, it tells you how long it took to
    perform the conversion.

    If you do not like this verbose behavior, use the `--quiet` or `-q`
    argument to run pandocomatic quietly. Default is `false`.

`-y, --dry-run`

:   Inspect the files and directories to convert, but do not actually
    run the conversion. Default is `false`.

### Conventional arguments: help and version

`-v, --version`

:   Show the version. If this option is used, all other options
    are ignored.

`-h, --help`

:   Show a short help message. If this options is used, all other
    options except `--version` or `-v` are ignored.

Examples
--------

Convert `hello.md` to `hello.html` according to the configuration in
`pandocomatic.yaml`:

``` {.bash}
pandocomatic --config pandocomatic.yaml -o hello.html -i hello.md
```

Generate a static site using data directory `assets`, but only convert
files that have been updated since the last time pandocomatic has been
run:

``` {.bash}
pandocomatic --data-dir assets/ -o website/ -i source/ -m
```

Generate the markdown files for pandocomatic's
[manual](https://heerdebeer.org/Software/markdown/pandocomatic/) and its
[github repository](https://github.com/htdebeer/pandocomatic) README:

``` {.bash}
git clone https://github.com/htdebeer/pandocomatic.git
cd docoumentation
pandocomatic --data-dir data-dir --config config.yaml -i README.md -o ../README.md
pandocomatic --data-dir data-dir --config config.yaml -i manual.md -o ../index.md
```

Be careful to not overwrite the input file with the output file! I would
suggest using different names for both, or different directories.
Looking more closely to the pandocomatic configuration file
`config.yaml`, we see it contains one template, `mddoc`:

``` {.yaml}
templates:
  mddoc:
    pandoc:
      from: markdown
      to: markdown
      standalone: true
      filter: 
      - filters/insert_document.rb
      - filters/insert_code_block.rb
      - filters/remove_pandocomatic_metadata.rb
```

The `mddoc` template tells pandocomatic to convert a markdown file to a
standalone markdown file using three filters: `insert_document.rb`,
`insert_code~block.rb`, and `remove_pandocomatic_metadata.rb`. The first
two filters allow you to include another markdown file or to include a
source code file (see the README listing below). The last filter removes
the pandocomatic metadata block from the file so the settings in it do
not interfere with the translation of the manual to HTML when it is
generated as part of the website. These filters are located in the
[`filters`](https://github.com/htdebeer/pandocomatic/tree/master/documentation/data-dir/filters)
subdirectory in the specified data directory `data-dir`.

However, the `mddoc` template converts from and to pandoc's markdown
variant, which differs slightly from the markdown variant used by
[Github](https://github.com/) for README files. Luckily, pandoc does
support writing Github's markdown variant. There is no need to create
and use a different template for generating the README, though, as you
can override all template's settings inside a pandocomatic block in a
markdown file:

``` {.markdown}
---
pandocomatic:
  use-template: mddoc
  pandoc:
    to: markdown_github
...

# Pandocomatic—Automating the use of pandoc

::paru::insert introduction.md

## Why pandocomatic?

::paru::insert why_pandocomatic.md

## Licence

::paru::insert license.md

## Installation

::paru::insert install.md

## Examples

::paru::insert usage_examples.md

## More information

See [pandocomatic's
manual](https://heerdebeer.org/Software/markdown/pandocomatic/) for more
extensive examples of using pandocomatic. Notably, the manual contains two
typical use cases of pandocomatic:

1.  automating setting up and running pandoc for a series of related papers
    and
2.  using pandocomatic as a static site generator.
```

Here you see that the README uses the `mddoc` template and it overwrites
the `to` property with `markdown_github`.

See Chapters 4 & 5 for more extensive examples of using pandocomatic.

In the next chapter the configuration of pandocomatic is elaborated.

Configuring pandocomatic
========================

Pandocomatic is configured by command line options and configuration
files. Each input file that is converted by pandocomatic is processed as
follows:

    input_file -> 
      preprocessor(0) -> ... -> preprocessor(N) ->
        pandoc -> 
          postprocessor(0) -> ... -> postprocessor(M) -> 
            output_file

The preprocessors and postprocessors used in the conversion process are
configured in pandocomatic templates. Besides processors, you can also
specify pandoc options to use to convert an input file. These templates
are specified in a configuration file. Templates can be used over and
over, thus automating the use of pandoc.

Configuration files are [YAML](http://www.yaml.org/) files and can
contain the following properties:

-   **settings**:
    -   **skip**: An array of glob patterns of files and directories to
        not convert. By default hidden files (starting with a ".") and
        "pandocomatic.yaml" are skipped.
    -   **recursive**: A boolean telling pandocomatic to convert the
        subdirectories of a directory as well. By default this setting
        is `true`.
    -   **follow\_links**: A boolean telling pandocomatic to follow
        symbolic links. By default is `true`. Note, links that point
        outside the input source's directory tree will not be visited.
-   **templates**:
    -   **glob**: An array of glob patterns of files to convert using
        this template.
    -   **preprocessors**: An array of scripts to run on an input file
        before converting the output of those scripts with pandoc.
    -   **pandoc**: Pandoc options to use when converting an input file
        using this template.
    -   **postprocessors**: An array of scripts to run on the result of
        the pandoc conversion. The output of these scripts will be
        written to the output file.

Each file and directory that is converted can contain a configuration
YAML metadata block or a YAML configuration file respectively. In a
file, the property *use-template* tells pandocomatic which template to
use to convert that file.

See the next two chapters for more extensive examples of using and
configuring pandocomatic.

Use case I: Automating setting up and running pandoc for a series of related papers
===================================================================================

In this chapter I will elaborate the example from the Introduction about
using pandocomatic to configure and run pandoc for a series of related
research papers.

Use case II: Use pandocomatic as a static site generator
========================================================

to be done
