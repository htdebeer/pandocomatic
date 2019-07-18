---
author: Huub de Beer
date: 'April 6th, 2019'
keywords:
- pandoc
- ruby
- paru
- pandocomatic
- static site generator
subtitle: Automate the use of pandoc
title: Pandocomatic
---

Introduction
============

Pandocomatic is a tool to automate the use of
[pandoc](https://pandoc.org/). With pandocomatic you can express common
patterns of using pandoc for generating your documents. Applied to a
directory, pandocomatic can act as a static site generator. For example,
this manual is generated with pandocomatic!

Pandocomatic is [free
software](https://www.gnu.org/philosophy/free-sw.en.html); pandocomatic
is released under the
[GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html). You will find the
source code of pandocomatic in its
[repository](https://github.com/htdebeer/pandocomatic) on
[Github](https://github.com).

Acknowledgements
----------------

I would like to thank [Ian](https://github.com/iandol) for his
contribution of patches, bug reports, fixes, and suggestions. With your
help pandocomatic is growing beyond a simple tool for personal use into
a useful addition to the pandoc ecosystem.

Installation
------------

Pandocomatic is a [Ruby](https://www.ruby-lang.org/en/) program and can
be installed through [RubyGems](https://rubygems.org/) as follows:

``` {.bash}
gem install pandocomatic
```

This will install pandocomatic and
[paru](https://heerdebeer.org/Software/markdown/paru/), a Ruby wrapper
around pandoc. To use pandocomatic, you also need a working pandoc
installation. See [pandoc's installation
guide](https://pandoc.org/installing.html) for more information about
installing pandoc.

You can also download the latest gem,
[pandocomatic-0.2.5.4](https://github.com/htdebeer/pandocomatic/blob/master/releases/pandocomatic-0.2.5.4.gem),
from Github and install it manually as follows:

``` {.bash}
cd /directory/you/downloaded/the/gem/to
gem install pandocomatic-0.2.5.4.gem
```

Why pandocomatic?
-----------------

I use pandoc a lot. I use it to write all my papers, notes, websites,
reports, outlines, summaries, and books. Time and again I was invoking
pandoc like:

``` {.bash}
pandoc --from markdown \
  --to html \
  --standalone \
  --csl apa.csl \
  --bibliography my-bib.bib \
  --mathjax \
  --output result.html \
  source.md
```

Sure, when I write about history, the [CSL](https://citationstyles.org/)
file and bibliography change. And I do not need the `--mathjax` option
like I do when I am writing about mathematics education. Still, all
these invocations are quite similar.

I already wrote the program *do-pandoc.rb* as part of a Ruby wrapper
around pandoc, [paru](https://heerdebeer.org/Software/markdown/paru/).
Using *do-pandoc.rb* I can specify the options to pandoc in a metadata
block in the source file itself. With *do-pandoc.rb* the invocation
above is simplified to:

``` {.bash}
do-pandoc.rb source.md
```

It saves me from typing out the whole pandoc invocation each time I run
pandoc on a source file. However, I have still to setup the same options
to use in each document that I am writing, even though these options do
not differ that much from document to document.

*Pandocomatic* is a tool to re-use these common configurations by
specifying a so-called *pandocomatic template* in a
[YAML](https://yaml.org/) configuration file. For example, by placing
the following file, `pandocomatic.yaml`, in pandoc's data directory:

``` {.yaml}
templates:
  education-research:
    preprocessors: []
    pandoc:
      from: markdown
      to: html
      standalone: true
      csl: 'apa.csl'
      toc: true
      bibliography: /path/to/bibliography.bib
      mathjax: true
    postprocessors: []
```

In this configuration file a single *pandocomatic template* is being
defined: *education-research*. This template specifies that the source
files it is applied to are not being preprocessed. Furthermore, the
source files are converted with pandoc by invoking
`pandoc --from markdown --to html --standalone --csl apa.csl --toc --bibliography /path/to/bibliography.bib --mathjax`.
Finally, the template specifies that pandoc's output is not being
postprocessed.

I now can create a new document that uses this template by including the
following metadata block in my source file, `on_teaching_maths.md`:

``` {.pandoc}
 ---
 title: On teaching mathematics
 author: Huub de Beer
 pandocomatic_:
   use-template: education-research
   pandoc:
     output: on_teaching_mathematics.html
 ...
 
 Here goes the contents of my new paper ...
```

To convert this file to `on_teaching_mathematics.html` I run
pandocomatic:

``` {.bash}
pandocomatic -i on_teaching_maths.md
```

With just two extra lines in a metadata block I can tell pandocomatic
what template to use when converting a file. You can also use multiple
templates in a document, for example to convert a markdown file to both
HTML and PDF. Adding file-specific pandoc options to the conversion
process is as easy as adding a `pandoc` property with those options to
the `pandocomatic_` metadata property in the source file like I did with
the `output` property in the example above.

Once I had written a number of related documents this way, it was a
small step to enable pandocomatic to convert directories as well. Just
like that, pandocomatic can be used as a *static site generator*!

------------------------------------------------------------------------

Using pandocomatic: Quick start and overview {#using-pandocomatic}
============================================

Converting a single document
----------------------------

Pandocomatic allows you to put [pandoc command-line
options](http://pandoc.org/MANUAL.html) in the document to be converted
itself. Instead of a complex pandoc command-line invocation,
pandocomatic allows you to convert your markdown document
`hello_world.md` with just:

``` {.bash}
pandocomatic hello_world.md
```

Pandocomatic starts by extracting the YAML metadata blocks in
`hello_world.md`, looking for a `pandocomatic_` property. If such a
property exists, it is treated as an **internal pandocomatic template**
and the file is converted according to that **pandocomatic template**.
For more information about *pandocomatic template*s, see the [chapter
about templates](#pandocomatic-templates) later in this manual.

For example, if `hello_world.md` contains the following pandoc markdown
text:

``` {.pandoc}
 ---
 title: My first pandocomatic-converted document
 pandocomatic_:
     pandoc:
         to: html
 ...
 
 Hello *World*!
```

pandocomatic is instructed by the `pandoc` property to convert the
document to the HTML file `hello_world.html`. If you would like to
instruct pandocomatic to convert `hello_world.md` to
`goodday_world.html` instead, use command-line option
`--output goodday_world.html`. For more information about pandocomatic's
command-line options, see the [chapter about command-line
options](#pandocomatic_cli).

You can tell pandocomatic to apply any pandoc command-line option in a
template's `pandoc` property. For example, to use a custom pandoc
template and add a custom CSS file to the generated HTML, extend the
`pandoc` property above as follows:

``` {.yaml}
pandoc:
    to: html
    css:
    -   style.css
    template: hello-template.html
```

Besides the `pandoc` property to configure the pandoc conversion,
*pandocomatic templates* can also contain a list of **preprocessors**
and a list of **postprocessors**. Preprocessors are run before the
document is converted with pandoc and postprocessors are run afterwards
(see the Figure below):

![How pandocomatic works: a simple
conversion](documentation/images/simple_conversion.svg)

For example, you can use the following script to clean up the HTML
generated by pandoc:

``` {.bash}
 #!/bin/bash
 tidy -quiet -indent -wrap 78 -utf8
```

This script `tidy.sh` is a simple wrapper script around the
[html-tidy](https://www.html-tidy.org/) program. To tell pandocomatic to
use it as a postprocessor, you have to change the `pandocomatic_`
property to:

``` {.yaml}
pandocomatic_:
    pandoc:
        to: html
        css:
        -   style.css
        template: hello-template.html
    postprocessors:
    - ./tidy.sh
```

The "`./`" in the path `./tidy.sh` tells pandocomatic to look for the
`tidy.sh` script in the same directory as the file to convert. You can
also specify an absolute path (starting with a slash "`/`") or a path
relative to the **pandocomatic data directory** like we do in the path
in the `template` property in the example above. See the [Section about
specifying paths in pandocomatic](#specifying-paths) for more
information. If you use a path relative to the *pandocomatic data
directory*, you have to use the `--data-dir` option to tell pandocomatic
where to find its data directory. If you do not, pandocomatic will
default to pandoc's data directory.

To convert the example with a data directory, use:

``` {.bash}
pandocomatic --data-dir my_data_dir hello_world.md
```

Like pandoc, pandocomatic does support multiple input files. These input
files are concatenated by pandocomatic and then treated as a single
input file. For example, instead of writing a book in one big markdown
file, you could separate the chapters into separate markdown files. To
generate the final book, invoke pandocomatic like:

``` {.bash}
pandocomatic -i frontmatter.md -i c01.md -i c02.md -i c03.md -i c04.md -o book.html
```

Note. If multiple files do have a `pandocomatic_` property in their
metadata blocks, only the first `pandocomatic_` property is used; all
other occurrences are discarded. If this happens, pandocomatic will show
a warning.

Converting a series of documents
--------------------------------

### Using external templates

Adding an *internal pandocomatic template* to a markdown file helps a
lot by simplifying converting that file with pandoc. Once you start
using pandocomatic more and more, you will discover that most of these
*internal pandocomatic templates* are a lot alike. You can re-use these
*internal pandocomatic templates* by moving the common parts to an
**external pandocomatic template**.

*External pandocomatic template*s are defined in a **pandocomatic
configuration file**. A *pandocomatic configuration file* is a YAML
file. Templates are specified in the `templates` property as named sub
properties. For example, the *internal pandocomatic template* specified
in the `hello_world.md` file (see previous chapter) can be specified as
the *external pandocomatic template* `hello` in the *pandocomatic
configuration file* `my-config.yaml` as follows:

``` {.yaml}
 templates:
     hello:
         pandoc:
             to: html
             css:
                 - ./style.css
             template: hello-template.html
         postprocessors:
             - ./tidy.sh
```

You use it in a pandoc markdown file by specifying the `use-template`
sub property in the `pandocomatic_` property. The `hello_world.md`
example then becomes:

``` {.pandoc}
  ---
  title: My second pandocomatic-converted document
  pandocomatic_:
      use-template: hello
  ...
  
  Hello *World*!
```

To convert `external_hello_world.md` you need to tell pandocomatic where
to find the *external pandocomatic template* via the `--config`
command-line option. For example, to convert `external_hello_world.md`
to `out.html`, use:

``` {.bash}
pandocomatic -d my_data_dir --config my-config.yaml -i external_hello_world.md -o out.html
```

### Customizing external templates with an internal template

Because you can use an *external pandocomatic templates* in many files,
these external templates tend to setup more general aspects of a
conversion process. You can customize a such a general conversion
process in a specific document by extending the *internal pandocomatic
template*. For example, if you want to apply a different CSS style sheet
and add a table of contents, customize the `hello` template with the
following *internal pandocomatic template*:

``` {.yaml}
pandocomatic_:
    use-template: hello
    pandoc:
        toc: true
        css:
            remove:
            - './style.css'
            add:
            - './goodbye-style.css'
```

`hello`'s `pandoc` property is extended with the `--toc` option, the
`style.css` is removed, and `goodbye-style.css` is added. If you want to
add the `goodbye-style.css` rather than having it replace `style.css`,
you specify:

``` {.yaml}
css:
    -   './goodbye-style.css'
```

Lists and properties in *internal pandocomatic templates* are merged
with *external pandocomatic templates*; simple values, such as strings,
numbers, or Booleans, are replaced. Besides a template's `pandoc`
property you can also customize any other property of the template.

### Extending templates

In a similar way that an *internal pandocomatic template* extends an
*external pandocomatic template* you can also **extend** an *external
pandocomatic template* directly in the *pandocomaitc configuration
file*. For example, instead of customizing the `hello` template, you
could also have extended `hello` as follows:

``` {.yaml}
 templates:
     hello:
         pandoc:
             to: html
             css:
                 - ./style.css
             template: hello-template.html
         postprocessors:
             - ./tidy.sh
     goodbye:
         extends: ['hello']
         pandoc:
             toc: true
             css:
                 - ./goodbye-style.css
```

The 'goodbye' template *extends* the `hello` template. A template can
*extend* multiple templates. For example, you could write a template
`author` in which you configure the `author` metadata variable:

``` {.yaml}
templates:
    author:
        metadata:
            author: Huub de Beer
    ...
```

This `author` template specifies the `metadata` property of a template.
This metadata will be mixed into each document that uses this template.
If you want the `goodbye` template to also set the author automatically,
you can change its `extends` property to:

``` {.yaml}
templates:
    ...
    goodbye:
        extends: ['author', 'hello']
        ...
```

Setting up templates by extending other smaller templates makes for a
modular setup. If you share your templates with someone else, they only
have to change the `author` template in one place to use their own names
on all their documents while using your templates.

See the [Section on extending pandocomatic
templates](#extending-pandocomatic-templates) for more information about
this extension mechanism.

Converting a directory tree of documents
----------------------------------------

Once you have created a number of documents that can be converted by
pandocomatic and you change something significant in one of the
*external pandocomatic templates*, you have to run pandocomatic on all
of the documents again to propagate the changes. That is fine for a
document or two, but more than that and it becomes a chore.

For example, if you change the HTML template `hello-template.html` in
the *pandocomatic data directory*, or switch to another template, you
need to regenerate all documents you have already converted with the old
HTML template. If you run pandocomatic on an input directory rather than
on an input file, it will convert all files in that directory,
recursively.

Thus, to convert the example files used in this chapter, you can run

``` {.bash}
pandocomatic -d my_data_dir -c my-extended-config.yaml -i manual -o output_dir
```

It will convert all files in the directory `manual` and place the
generated documents in the output directory `output_dir`.

From here it is but a small step to use pandocomatic as a **static-site
generator**. For that purpose some configuration options are available:

-   a settings property in a *pandocomatic configuration file* to
    control
    -   running pandocomatic recursively or not
    -   follow symbolic links or not
-   a `glob` property in an *external pandocomatic template* telling
    pandocomatic which files in the directory to apply the template to.
    As a convention, a file named `pandocomatic.yaml` in a directory is
    used as the *pandocomatic configuration file* to control the
    conversion of the files in that directory
-   a command-line option `--modified-only` to only convert the files
    that have changes rather than to convert all files in the directory.

With these features, you can (re)generate a website with the
pandocomatic invocation:

``` {.bash}
pandocomatic -d data_dir -c intitial_config.yaml -i src -o www --modified-only
```

For more detailed information about pandocomatic, please see the
[Reference](#reference) section of this manual.

------------------------------------------------------------------------

Reference: All about pandocomatic {#reference}
=================================

Pandocomatic command-line interface {#pandocomatic-cli}
-----------------------------------

Pandocomatic takes a number of arguments which should at least include
the input file or directory. The general form of a pandocomatic
invocation is:

``` {.bash}
pandocomatic options [INPUT]
```

### General arguments: help and version

`-v, --version`

:   Show the version. If this option is used, all other options are
    ignored.

`-h, --help`

:   Show a short help message. If this option is used, all other options
    except `--version` or `-v` are ignored.

### Input/output arguments

`-i PATH, --input PATH`

:   Convert `PATH`. If this option is not given, `INPUT` is converted.
    `INPUT` and `--input` or `-i` cannot be used together. You can use
    this option multiple times, denoting to concatenate each input file
    in the order they are specified on the command-line. Pandocomatic
    treats the concatenated files as a single input file.

`-o PATH, --output PATH`

:   Create converted files and directories in `PATH`.

    You can specify the output file in the metadata of a pandoc markdown
    input file. In that case, you can omit the output argument.
    Furthermore, if no output file is specified whatsoever, pandocomatic
    defaults to output to HTML by replacing the extension of the input
    file with `html`.

The input and output should both be files or both be directories.
Pandocomatic will complain if the input and output types do not match.

### Arguments to configure pandocomatic

`-d DIR, --data-dir DIR`

:   Configure pandocomatic to use `DIR` as its data directory. The
    default data directory is pandoc's data directory. (Run
    `pandoc --version` to find pandoc's data directory on your system.)

`-c FILE, --config FILE`

:   Configure pandocomatic to use `FILE` as its configuration file
    during the conversion process. Default is
    `DATA_DIR/pandocomatic.yaml`.

### Arguments to change how pandocomatic operates

`-m, --modified-only`

:   Only convert files that have been modified since the last time
    pandocomatic has been run. Or, more precisely, only those source
    files that have been updated at a later time than the corresponding
    destination files will be converted, copied, or linked. Default is
    `false`.

`-q, --quiet`

:   By default pandocomatic is verbose when you convert a directory. It
    tells you about the number of commands to execute. When executing
    these commands, pandocomatic tells you what it is doing, and how
    many commands still have to be executed. Finally, when pandocomatic
    is finished, it tells you how long it took to perform the
    conversion.

    If you do not like this verbosity, use the `--quiet` or `-q`
    argument to run pandocomatic quietly. Default is `false`.

`-y, --dry-run`

:   Inspect the files and directories to convert, but do not actually
    run the conversion. Default is `false`.

`-b, --debug`

:   Run pandocomatic in debug mode. At the moment this means that all
    pandoc invocations are printed as well.

### Status codes

When pandocomatic runs into a problem, it will return with status codes
`1266` or `1267`. The former is returned if something goes wrong before
any conversion is started and the latter when something goes wrong
during the conversion process.

Pandocomatic configuration
--------------------------

Pandocomatic can be configured by means of a *pandocomatic configuration
file*, which is a YAML file. For example, the following YAML code is a
valid *pandocomatic configuration file*:

``` {.yaml}
 settings:
     data-dir: ~/my_data_dir
     recursive: true
     follow-links: false
     skip: ['.*']
 templates:
     webpage:
         glob: ['*.md']
         pandoc:
             to: html
             toc: true
             css:
                 - assets/style.css
         postprocessors:
             - postprocessors/tidy.sh
```

By default, pandocomatic looks for the configuration file in the
*pandocomatic data directory*; by convention this file is named
`pandocomatic.yaml`.

You can tell pandocomatic to use a different configuration file via the
command-line option `--config`. For example, if you want to use a
configuration file `my-config.yaml`, invoke pandocomatic as follows:

``` {.bash}
pandocomatic --config my-config.yaml some-file-to-convert.md
```

A *pandocomatic configuration file* contains two properties:

1.  global `settings`
2.  external `templates`

These two properties are discussed after presenting an example of a
configuration file. For more in-depth information about pandocomatic
templates, please see the [Chapter on pandocomatic
templates](#pandocomatic-templates).

### Settings

You can configure five optional global settings:

1.  `data-dir`
2.  `match-files`
3.  `skip`
4.  `recursive`
5.  `follow-links`

The latter three are used only when converting a whole directory tree
with pandocomatic. These are discussed in the next sub section.

The first setting, `data-dir` (String), tells pandocomatic where its
*data directory* is. You can also specify the *pandocomatic data
directory* via the command-line option `--data-dir`. For example, if you
want to use `~/my-data-dir` as the *pandocomatic data directory*, invoke
pandocomatic as follows:

``` {.bash}
pandocomatic --data-dir ~/my-data-dir some-file-to-convert.md
```

If no *pandocomatic data directory* is specified whatsoever,
pandocomatic defaults to pandoc's data directory.

Any directory can be used as a *pandocomatic data directory*, there are
no conventions or requirements for this directory other than being a
directory. However, it is recommended to create a meaningful sub
directory structure. For example, a sub directory for processors,
filters, CSL files, and pandoc templates makes it easier to manage and
point to these assets.

The setting `match-files` controls how pandocomatic selects the template
to use to convert a file. Possible values for `match-files` are `first`
and `all`. Pandocomatic matches a file to a template as follows:

1.  If the file has one or more `use-template` statements in the
    *pandocomatic* metadata, it will use these specified templates.

2.  However, if no such templates are specified in the file,
    pandocomatic tries to find *global* templates as follows:

    a.  If the setting `match-files` has value `all`, all templates with
        a glob pattern that matches the input filename are used to
        convert that input file. For example, you can specify a template
        `www` to convert `*.md` files to HTML and a template `pdf` to
        convert `*.md` to PDF. In this case, a markdown file will be
        converted to both HTML and PDF. For example, you could use this
        to generate a website with a print PDF page for each web page.

    b.  If the setting `match-files` has value `first`, the first
        template with a glob pattern that matches the input file is used
        to convert the file.

        This is the default.

#### Configuring converting a directory tree {#global-settings}

You can convert a directory tree by invoking pandocomatic with a single
directory as the input rather than one or more files. Of course, once
you start converting directories, more fine-grained control over what
files to convert than "convert all files" is useful. There are four
settings you can use to control which files to convert. Three of them
are global settings, the other one is the `glob` property of an
*external pandocomatic template*. The `glob` property is discussed
later.

The three global settings to control which files to convert are:

1.  `recursive` (Boolean), which tells pandocomatic to convert sub
    directories or not. This setting defaults to `true`.
2.  `follow-links` (Boolean), which tells pandocomatic to treat symbolic
    links as files and directories to convert or not. This setting
    defaults to `false`.
3.  `skip` (Array of glob patterns), which tells pandocomatic which
    files not to convert at all. This setting defaults to
    `['.*', 'pandocomatic.yaml']`: ignore all hidden files (starting
    with a period) and also ignore default *pandocomatic configuration
    files*.

#### Default configuration

Pandocomatic's default configuration file is defined in the file
[`lib/pandocomatic/default_configuration.yaml`](https://github.com/htdebeer/pandocomatic/blob/master/lib/pandocomatic/default_configuration.yaml).
This default configuration is used when

-   no configuration is specified via the command-line option
    `--config`, and
-   no default configuration file (`pandocomatic.yaml`) can be found in
    the *pandocomatic data directory*.

When converting a directory tree, each time pandocomatic enters a (sub)
directory, it also looks for a default configuration file to *update*
the current settings. In other words, you can have pandocomatic behave
differently in a sub directory than the current directory by putting a
`pandocomatic.yaml` file in that sub directory that changes the global
settings or *external pandocomatic templates*.

### Templates

Besides the global `settings` property, a *pandocomatic configuration
file* can also contain a `templates` property. In the `templates`
property you define the *external pandocomatic templates* you want to
use when converting files with pandocomatic. Pandocomatic templates are
discussed in detail in the [Chapter on pandocomatic
templates](#pandocomatic-templates). The `glob` property of *external
pandocomatic templates* is related to configuring pandocomatic when
converting a directory. It tells pandocomatic which files in a directory
are to be converted with a template.

If you look at the example *pandocomatic configuration file* at the
start of this chapter, you see that the `webpage` template is configured
with property `glob: ['*.md']`. This tells pandocomatic to apply the
template `webpage` to all markdown files with extension `.md`. In other
words, given a directory with the following files:

    directory/
    + sub directory/
    | + index.md
    - index.md
    - image.png 

Running pandocomatic with the example *pandocomatic configuration file*
will result in the following result\"

    directory/
    + sub directory/
    | + index.html
    - index.html
    - image.png 

That is, all `.md` files are converted to HTML and all other files are
copied, recursively.

Pandocomatic templates
----------------------

Pandocomatic automates the use of pandoc by extracting common patterns
of using pandoc into so called *pandocomatic templates*. You can then
apply these templates to your documents. As described in [Part
II](#using-pandocomatic), there are **internal** and **external**
*pandocomatic templates*. The difference between these two types of
templates is their scope: *internal pandocomatic templates* only affect
the document they are defined in, whereas *external pandocomatic
templates*, which are defined in a *pandocomatic configuration file*,
affect all documents that use that template.

Although you can create an one-off *internal pandocomatic template* for
a document---sometimes you just have an odd writing project that differs
too much from your regular writings---, most often you use an *external
pandocomatic template* and customize it in the *internal pandocomatic
template*.

In this Chapter the definition, extension, customization, and use of
templates are discussed in detail.

### Defining a template

An *external pandocomatic template* is defined in the `templates`
property of a *pandocomatic configuration file*. For example, in the
following YAML code, the template `webpage` is defined:

``` {.yaml}
 settings:
     data-dir: ~/my_data_dir
     recursive: true
     follow-links: false
     skip: ['.*']
 templates:
     webpage:
         glob: ['*.md']
         pandoc:
             to: html
             toc: true
             css:
                 - assets/style.css
         postprocessors:
             - postprocessors/tidy.sh
```

Each template is a sub property in the `templates` property. The
property name is the template name. The property value is the template's
definition. A template definition can contain the following sub
properties:

-   `extends`
-   `glob`
-   `setup`
-   `preprocessors`
-   `metadata`
-   `pandoc`
-   `postprocessors`
-   `cleanup`

Before discussing these properties in detail, the way pandocomatic
resolves paths used in these sections is described first because paths
can be used in most of these properties.

#### Specifying paths

Because templates can be used in any document, specifying paths pointing
to assets to use in the conversion process is not straightforward. Using
global paths works, but has the disadvantage that the templates are no
longer easily shareable with others. Using local paths works if the
assets and the document to convert are located in the same directory,
but that does not hold for more general *external pandocomatic
templates*. As a third alternative, pandocomatic also supports paths
that are relative to the *pandocomatic data directory*.

You can specify these types of paths as follows:

1.  All *local* paths start with `./`. These paths are local to the
    document being converted. When converting a directory tree, the
    current directory is being prepended to the path minus the `./`.

    On the Windows operating system, a *local* path starts with `.\`.
    Note that backslashes might need escaping, like `.\\`.

2.  *Global* paths start with a `/`. These paths are resolved as is. On
    the Windows operating system, a *global* path starts with a letter
    followed by a colon and a backslash, for example `C:\`. Note that
    backslashes might need escaping, like `C:\\`.

3.  Paths *relative* to the *pandocomatic data directory* do not start
    with a `./` nor a `/`. These paths are resolved by prepending the
    path to the *pandocomatic data directory*. These come in handy for
    defining general usable *external pandocomatic templates*.

    *Note.* For filters, processors, and start-up or clean-up scripts,
    the path is first checked against the `PATH`. If pandocomatic finds
    an executable matching the path, it will resolve that executable
    instead.

#### Template properties

##### extends

A template can extend zero or more templates by supplying a list of
template names to extend. The extension builds from left to right.

For more detailed information about extending templates, see the
[Section about extending templates](#extending-pandocomatic-templates)
below.

**Examples**

-   Extend from template `webpage`:

    ``` {.yaml}
    extends: ['webpage']
    ```

    If only one template is extended, a string value is also allowed.
    The following has the same effect as the example above:

    ``` {.yaml}
    extends: webpage
    ```

-   Extend from templates `webpage` and `overview`:

    ``` {.yaml}
    extends: ['webpage', 'overview']
    ```

    Note. If both templates have overlapping or contradictory
    configuration, the above extension can be different from the one
    below:

    ``` {.yaml}
    extends: ['overview', 'webpage']
    ```

##### glob

When a template is used for converting files in a directory tree, you
can specify which files in the directory should be converted by a
template. The `glob` section expects a list of [glob
patterns](http://ruby-doc.org/core-2.4.1/Dir.html#method-c-glob). All
files that match any of these glob patterns are converted using this
template.

When there are more templates that have matching glob patterns, the
first one is used.

If there is also a `skip` configured (see the [Section on global
settings](#global-settings), the `skip` setting has precedence over the
`glob` setting. Thus, if `skip` is `['*.md']` and `glob` is `['*.md']`,
the template will not be applied.

**Examples**

-   Apply this template to all files with extension `.md` (i.e. all
    markdown files):

    ``` {.yaml}
    glob: ['*.md']
    ```

-   Apply this template to all HTML files and all files starting with
    `overview_`:

    ``` {.yaml}
    glob: ['overview_*', '*.html']
    ```

##### setup

For more involved conversion patterns, some setup of the environment
might be needed. Think of setting Bash environment variables, creating
temporary directories, or even installing third party tools needed in
the conversion. Startup scripts can be any executable script or program.

Setup scripts are run before the conversion process starts.

**Examples**

-   ``` {.yaml}
    setup:
    - scripts/create_working_directory.sh
    ```

##### preprocessors

After setup, pandocomatic executes all preprocessors in order of
specification in the `preprocessor` property, which is a list. A
preprocessor is any executable script or program that takes as input the
document to convert and outputs that document after "preparing" it
somehow. You can use a preprocessor to add metadata, include other
files, replace strings, and so on.

**Examples**

-   Add the today's date to the metadata:

    ``` {.yaml}
    preprocessors: ['preprocessors/today.sh']
    ```

    Note. You can also use a [filter to mix in the
    date](https://github.com/htdebeer/paru/blob/master/examples/filters/add_today.rb).

##### metadata

Metadata is used in pandoc's templates as well as a means of
communicating with a filter. Some metadata is common to many documents,
such as language, author, keywords, and so on. In the `metadata`
property of a template you can specify this global metadata. The
`metadata` property is a key-value list.

**Examples**

-   For example, all document I write have me as the author:

    ``` {.yaml}
    metadata:
        author: Huub de Beer
    ```

##### pandoc

To actually control the pandoc conversion process itself, you can
specify any pandoc command-line option in the `pandoc` property, which
is a key-value list.

**Examples**

-   Convert markdown to a standalone HTML document with a table of
    contents:

    ``` {.yaml}
    pandoc:
        from: markdown
        to: html
        toc: true
        standalone: true
    ```

-   Convert markdown to ODT with citations:

    ``` {.yaml}
    pandoc:
        from: markdown
        to: odt
        bibliography: 'assets/bibligraphy.bib'
        toc: 'assets/APA.csl'
    ```

For convenience, the virtual output format `pdf` is added by
pandocomatic. It allows you to specify PDF output without needing to use
the `output` option. This allows for general pandoc configurations for
generating PDF files. You specify the PDF output format by `to: pdf`.
Pandocomatic will determine the actual output format based on the value
of `pdf-engine`. If that option is not set, pandocomatic defaults to
`latex`.

To give the use more control over what filename extension will be used,
the virtual pandoc option `use-extension` has been added. If set, and
the `output` option is not being used, the value of the `use-extension`
option is used as the extension of the output file. For example, to
generate a PDF presentation using the beamer output format, you can
specify the following pandoc options:

``` {.yaml}
pandoc:
    from: markdown
    to: beamer
    use-extension: pdf
```

Finally, the virtual pandoc option `rename` has been added to allow you
to rename the output file via a script. This script will receive the
destination path on `STDIN` and is supposed to write the renamed output
path to `STDOUT`. It allows you to perform quite complex behavior with
regards to the output directory and name of output files.

I use this virtual pandoc option when I am generating my static sites
with both HTML and PDF output and my input file is named `index.md`. For
the HTML format I want `index.html` as the output file name, but for the
PDF output I do not want `index.pdf` as output filename. Instead, I
prefer to use the name of the input directory with extenstion `.pdf`. To
that end I setup pandocomatic as follows:

``` {.yaml}
pandoc:
    from: markdown
    to: pdf
    rename: use-dirname.rb
```

and `use-dirname.rb`:

``` {.ruby}
#!/usr/bin/env ruby

current_dst = $stdin.read
current_dst_dir = File.dirname current_dst
current_dst_filename = File.basename current_dst
current_dst_extname = File.extname current_dst

dirname = File.split(current_dst_dir).last

if current_dst_filename.start_with? "index" and not dirname.nil?
    puts File.join(current_dst_dir, "#{dirname}.#{current_dst_extname}")
else 
    puts current_dst
end
```

##### postprocessors

Similar to the `preprocessors` property, the `postprocessors` property
is a list of scripts or programs to run after the pandoc conversion has
finished. Each postprocessor takes as input the converted document and
outputs that document with the changes made by the postprocessor.
Postprocessors come in handy for cleaning up output, checking for dead
links, do string replacing, and so on.

**Examples**

-   Clean up the HTML generated by pandoc through the `tidy` program:

    ``` {.yaml}
    postprocessors: ['postprocessors/tidy.sh']
    ```

##### cleanup

The counterpart of the `setup` property. The `cleanup` property is a
list of scripts or programs to run after the conversion of the document.
It can be used to clean up temporary files, resetting the environment,
uploading the resulting document, and so on.

**Examples**

-   Deploy a generated HTML file to your website:

    ``` {.yaml}
    cleanup: ['scripts/upload_and_remove.sh']
    ```

### Extending pandocomatic templates

Using the `extends` property of a template, you can mix and extend
multiple templates. For example, building on the `webpage` template, I
can create a `my-webpage` template like so:

``` {.yaml}
 settings:
     data-dir: ~/my_data_dir
     recursive: true
     follow-links: false
     skip: ['.*']
 templates:
     author:
         metadata:
             author: Huub de Beer
     today:
         preprocessors:
             -   preprocessors/today.rb
     webpage:
         glob: ['*.md']
         pandoc:
             to: html
             toc: true
             css:
                 - assets/style.css
         postprocessors:
             - postprocessors/tidy.sh
     my-webpage:
         extends: ['author', 'today', 'webpage']
         pandoc:
             to: html5
             bibliography: 'assets/my-bibliography.bib'
```

This `my-webpage` templates extends the original by:

-   it always has my name as author
-   it sets "today" as the date so the date gets updated automatically
    whenever I convert a document with this template
-   and uses my bibliography for generating references.

#### Extension rules

Although extension of templates is relatively straightforward, there are
some nuances to the extension rules to keep in mind. Basically there are
three cases:

1.  If the parent template has a property, but the child does not, the
    resulting template has the parent's property. Examples:

        parent = 4 ∧ child = ⊘ ⇒ 4
        parent = [4, 5] ∧ child = ⊘ ⇒ [4, 5]

2.  If the parent template does not have a property, but the child does,
    the resulting template has the child's property.

        parent = ⊘ ∧ child = 4 ⇒ 4
        parent = ⊘ ∧ child = {a: 1} ⇒ {a: 1}

3.  If both parent and child templates do have a property, the resulting
    template will have that property and its value is determined as
    follows:

    1.  If the child's value is of a simple type, such as a string,
        number, or Boolean, the resulting property will have the value
        of the child. Examples:

            parent = 4 ∧ child = true ⇒ true
            parent = [4, 5] ∧ child = "yes" ⇒ "yes"
            parent = {key: true} ∧ child = 12 ⇒ 12

    2.  If parent and child values both are key-value lists, the
        resulting value will be the child's key-value list merged with
        the parent's key-value list. Examples:

            parent = {a: 1, b: 2} ∧ child = {a: 2, c: 3} ⇒ {a: 2, b: 2, c: 3}
            parent = {a: 1, b: 2} ∧ child = {a: , c: 3} ⇒ {b: 2, c: 3}

    3.  If the parent value is a list, two different extension
        mechanisms can take effect depending on the type of the child's
        value:

        1.  If the child is a list as well, the resulting value will be
            the child's list merged with the parent's list. Duplicate
            values will be removed. Lists in pandocomatic templates are
            treated as sets. Examples:

                parent = [1] ∧ child = [2] ⇒ [1, 2]
                parent = [1] ∧ child = [1, 2] ⇒ [1, 2]

        2.  If the child is a key-value list, it is assumed to have keys
            `remove` and `add`. The resulting value will be the parent's
            value with the items from the `remove` list removed and
            items from the `add` list added. Examples:

                parent = [1] ∧ child = {'remove': [1], 'add': [3]} ⇒ [3]
                parent = [1, 2] ∧ child = {'remove': [1]} ⇒ [2]

To remove a property in a child template, that child's value should be
`nil`. You can create a `nil` value in YAML by having a key without a
value.

### Customizing an external template in an internal template

To use an *external pandocomatic template* you have to use it in a
document by creating an *internal pandocomatic template* which has the
`use-template` property set to the name of the *external pandocomatic
template*. After that, you can customize the template to suit the
document it is used in, for example adding extra pandoc command-line
options or adding another preprocessor.

You create an *internal pandocomatic template* by adding a
`pandocomatic_` property to the document's YAML metadata. The
`pandocomatic_` property can have the same properties as an *external
pandocomatic template* except for the `glob` and `extends` properties.
(Actually, you can add these two properties as well, but they are
ignored.)

For example, if you use the `my-webpage` template, but you would like to
use a different bibliography and check all links in the converted
document, your document would look like:

``` {.pandoc}
 ---
 title: About using templates
 pandocomatic_:
     use-template: my-webpage
     pandoc:
         bibliography: ./a_different_bibliography.bib
     postprocessors:
     -   postprocessors/check_links.sh
 ...
 
 # Introduction
 
 To use a template, ...
```

#### Multiple conversions

The `use-template` property can also be a list of *external pandocomatic
template* names. In that case, the document is converted once for each
of these templates. For example, this allows you to generate both a HTML
and a PDF version of a document at the same time:

``` {.pandoc}
 ---
 title: About using templates
 pandocomatic_:
     use-template: 
     -   my-webpage
     -   my-pdf
     pandoc:
         bibliography: ./a_different_bibliography.bib
     postprocessors:
     -   postprocessors/check_links.sh
 ...
 
 # Introduction
 
 To use a template, ...
```

Do note, however, that an *internal pandocomatic template* will apply to
all used *external pandocomatic templates*. It is not possible to
customize one used template differently than another. This means that
you have to move the customization to the used *external pandocomatic
templates* or you have customize the *internal pandocomatic template*
such that it is applicable to all used *external pandocomatic templates*
(as in the example above).

------------------------------------------------------------------------

Appendix
========

Frequently asked questions (FAQ) {#faq}
--------------------------------

### How do I use pandoc2 with pandocomatic?

Pandocomatic uses [paru](https://heerdebeer.org/Software/markdown/paru/)
to run pandoc. Paru itself uses the `pandoc` executable in your `PATH`.
If that already is pandoc2, you do not need to do anything.

If you have pandoc1 installed by default, however, and you want to run a
[nightly version of
pandoc2](https://github.com/pandoc-extras/pandoc-nightly), you have to
set the `PARU_PANDOC_PATH` to point to the pandoc2 executable. For
example:

``` {.bash}
export PARU_PANDOC_PATH=~/Downloads/pandoc-amd64-7c20fab3/pandoc
pandocomatic some-file-to-convert.md
```

### Pandocomatic has too much output! How do I make pandocomatic more quiet?

You can run pandoc in quiet mode by using the `--quiet` or `-q`
command-line option. For example:

``` {.bash}
pandocomatic --quiet some-file-to-export.md
```

Glossary
--------

pandocomatic template

:   A pandocomatic template specified the conversion process executed by
    pandocomatic. It can contain the following properties:

-   glob
-   extends
-   setup
-   preprocessors
-   metadata
-   pandoc
-   postprocessors
-   cleanup

internal pandocomatic template

:   A pandocomatic template specified in a pandoc markdown file itself
    via the YAML metadata property `pandocomatic_`.

external pandocomatic template

:   A pandocomatic template specified in a *pandocomatic configuration
    file*.

preprocessors

:   A preprocessor applied to an input document before running pandoc.

postprocessors

:   A postprocessor applied to an input document after running pandoc.

pandocomatic data directory

:   The directory used by pandocomatic to resolve relative paths. Use
    this directory to store preprocessors, pandoc templates, pandoc
    filters, postprocessors, setup scripts, and cleanup scripts. It
    defaults to pandoc's data directory.

pandocomatic configuration file

:   The configuration file specifying *external pandocomatic templates*
    as well as settings for converting a directory tree. Defaults to
    `pandocomatic.yaml`.

extending pandocomatic templates

:   *External pandocomatic templates* can extend other *external
    pandocomatic templates*. By using multiple smaller *external
    pandocomatic templates* it is possible to setup your templates in a
    modular way. Pandocomatic supports extending from multiple *external
    pandocomatic templates*.

static-site generator

:   Pandocomatic can be used as a static-site generator by running
    pandocomatic recursivel on a directory. Pandocomatic has some
    specific congiguration options to be used as a static-site
    generator.

---
pandocomatic_:
    pandoc:
        filter:
        - './documentation/data-dir/filters/number_all_the_things.rb'
...
