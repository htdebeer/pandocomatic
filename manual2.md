---
author: Huub de Beer
date: 'September 21st, 2017'
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

Pandocomatic is a tool to automate the use of
[pandoc](http://pandoc.org/). With pandocomatic you can express common
patterns of using [pandoc](http://pandoc.org/) for generating your
documents. Applied to a directory, pandocomatic can act as a static site
generator. For example, this manual is generated with pandocomatic!

Pandocomatic is [free
software](https://www.gnu.org/philosophy/free-sw.en.html); pandocomatic
is released under the
[GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html). You'll find the
source code of pandocomatic in its
[repository](https://github.com/htdebeer/pandocomatic) on
[Github](https://github.com).

Installation
------------

Pandocomatic is a [Ruby](https://www.ruby-lang.org/en/) program and can
be installed through [RubyGems](https://rubygems.org/) as follows:

``` {.bash}
gem install pandocomatic
```

This will install pandocomatic and
[paru](https://heerdebeer.org/Software/markdown/paru/), a
[Ruby](https://www.ruby-lang.org/en/) wrapper around
[pandoc](http://pandoc.org/). To use pandocomatic, you also need a
working pandoc installation. See [pandoc's installation
guide](http://pandoc.org/installing.html) for more information about
installing pandoc.

You can also download the latest [gem](https://rubygems.org/)
[pandocomatic-0.1.4.18](https://github.com/htdebeer/pandocomatic/blob/master/releases/pandocomatic-0.1.4.18.gem)
from [Github](https://github.com) and install it manually as follows:

``` {.bash}
cd /directory/you/downloaded/the/gem/to
gem install pandocomatic-0.1.4.18.gem
```

Why pandocomatic?
-----------------

I use pandoc a lot. I use it to write all my papers, notes, websites,
reports, outlines, summaries, and books. Time and again I was invoking
pandoc like:

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

Sure, when I write about history, the [CSL](http://citationstyles.org/)
file and bibliography change. And I do not need the `--mathjax` option
like I do when I am writing about mathematics education. Still, all
these invocations are quite similar.

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
templates:
  education-research:
    preprocessors: []
    pandoc:
      from: markdown
      to: html5
      standalone: true
      csl: 'apa.csl'
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
 pandocomatic_:
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
template to use when converting a file. You can also use multiple
templates in a document, for example to convert a markdown file to both
HTML and PDF. Adding file-specific pandoc options to the conversion
process is as easy as adding a `pandoc` property with those options to
the `pandocomatic_` metadata property in the source file.

Once I had written a number of related documents this way, it was a
small step to enable pandocomatic to convert directories as well as
files. Just like that, pandocomatic can be used as a *static site
generator*!

------------------------------------------------------------------------

Using pandocomatic: Quick start and overview {#using-pandocomatic}
============================================

Converting a single document
----------------------------

Pandocomatic allows you to put [pandoc command line
options](http://pandoc.org/MANUAL.html) in the document to be converted
itself. Instead of a complex pandoc command line invocation,
pandocomatic allows you to convert your markdown document with just:

``` {.bash}
pandocomatic hello_world.md
```

Pandocomatic starts by mining the [YAML](http://yaml.org/) metadata in
`hello_world.md` for a `pandocomatic_` property. If such a property
exists, it is treated as an **internal pandocomatic template** and the
file is converted according to that **pandocomatic template**. For more
information about *pandocomatic template*s, see the [chapter about
templates](#pandocomatic-templates) in this manual.

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

pandocomatic is instructed by the `pandoc` section to convert the
document to the
[HTML](https://developer.mozilla.org/en-US/docs/Web/HTML) file
`hello_world.html`. With the command-line option
``` --output goodday_world.html``, you can instruct pandocomatic to convert ```hello\_world.md`to`goodday\_world.html\`
instead. For more information about pandocomatic's command-line options,
see the [chapter about command-line options](#pandocomatic_cli) in this
manual.

You can instruct pandocomatic to apply any pandoc command-line option in
the `pandoc` section. For example, to use a custom pandoc template and
add a [CSS](https://developer.mozilla.org/en-US/docs/Web/CSS) file to
the generated HTML, extend the `pandoc` section as follows:

``` {.yaml}
pandoc:
    to: html
    css:
    -   style.css
    template: hello-template.html
```

Besides the `pandoc` section to configure the pandoc conversion,
*pandocomatic templates* can also contain a list of **preprocessors**
and **postprocessors**. Preprocessors are run before the document is
converted with pandoc and postprocessors are run afterwards:

![How pandocomatic works: a simple
conversion](documentation/images/simple_conversion.svg)

For example, you can use the following script to clean up the HTML
generated by pandoc:

``` {.bash}
 #!/bin/bash
 tidy -quiet -indent -wrap 78 -utf8
```

This script `tidy.sh` is a simple wrapper script around the
[html-tidy](http://www.html-tidy.org/) program. To instruct pandocomatic
to use it as a postprocessor, you have to change the `pandocomatic_`
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

The path `./tidy.sh` tells pandocomatic to look for the `tidy.sh` script
in the same directory as the file to convert. You can also specify an
absolute path (starting with a slash `/`) or a path relative to the
**pandocomatic data directory** such as for the pandoc `template`. See
the [Section about specifying paths in pandocomatic](#specifiying-paths)
for more information. If you use a path relative to the *pandocomatic
data directory*, you have to use the `--data-dir` option to tell
pandocomatic where to find its data directory.

Thus, to convert the above example, use the following pandocomatic
invocation:

``` {.bash}
pandocomatic --data-dir my_data_dir hello_world.md
```

Converting a series of documents
--------------------------------

### Using external templates

Adding an *internal pandocomatic template* to a markdown file helps a
lot by simplifying converting that file via pandoc. Once you start using
pandocomatic more and more to convert your documents, you will discover
that most of these *internal pandocomatic templates* are a lot alike.
You can re-use these *internal pandocomatic templates* by moving the
common parts to an **external pandocomatic template**.

*External pandocomatic template*s are defined in a **pandocomatic
configuration file**. A *pandocomatic configuration file* is a YAML
file. Templates are specified in the `templates` section as named sub
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
option in the `pandocomatic_` property. The `hello_world.md` example
then becomes:

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
to `out.html`, you use the following pandocomatic invocation:

``` {.bash}
pandocomatic -d my_data_dir --config my-config.yaml -i external_hello_world.md -o out.html
```

### Customizing external templates with an internal template

Because you can use an *external pandocomatic templates* in many files,
these external templates tend to setup more general options of a
conversion process. You can customize a conversion process in a
particular document by extending the *internal pandocomatic template*.
For example, if you want to apply a different CSS style sheet and adding
a table of contents, customize the `hello` template with the following
*internal pandocomatic template*:

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

`hello`'s `pandoc` section if extended with the `--toc` option, the
`style.css` is removed, and `goodbye-style.css` is added. If you want to
add the `goodbye-style.css` rather than have it replace `style.css`, you
would specify:

``` {.yaml}
css:
    -   './goodbye-style.css'
```

Lists and properties in *internal pandocomatic templates* are merged
with *external pandocomatic templates*; simple values, such as strings,
numbers, or Booleans, are replaced. Besides the `pandoc` section of a
template you can also customize other template sections.

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

This `author` template specifies the `metadata` section of a template.
This metadata will be mixed into each document that uses this template.
If you want the `goodbye` template to also set the author automatically,
you can change its `extends` section to:

``` {.yaml}
templates:
    ...
    goodbye:
        extends: ['author', 'hello']
        ...
```

Setting up templates by extending other smaller templates makes for a
modular setup. If you share your templates with someone else, she only
has to change the `author` template to her own name in one place to
automatically put her name on all her documents while using your
templates.

See the [Section on extending pandocomatic
templates](#extending-pandocomatic-templates) for more information about
this extension mechanism.

Converting a directory tree of documents
----------------------------------------

Once you have created a number of documents that can be converted by
pandocomatic, and you change something significant in one of the
*external pandocomatic templates*, you have to run pandocomatic on all
of the documents again to propagate the changes. That is fine for a
document or two, but more than that and it becomes a chore.

For example, if you change the pandoc template `hello-template.html` in
the *pandocomatic data directory*, or switch to another template, you
need to regenerate all documents you have already converted with the old
pandoc template. If you run pandocomatic on an input directory rather
than one input file, it will convert all files in that directory,
recursively.

Thus, to convert the example files used in this chapter, you can run

``` {.bash}
pandocomatic -d my_data_dir -c my-extended-config.yaml -i manual -o output_dir
```

It will convert all files in the directory `manual` and place the
generated documents in the output directory `output_dir`.

From here it is but a small step to use pandocomatic as a **static-site
generator**. For that purpose some configuration options are available:

-   a settings section in a *pandocomatic configuration file* to control
    -   running pandocomatic recursively or not
    -   follow symbolic links or not
-   a `glob` section in an *external pandocomatic template* telling
    pandocomatic to apply the template to which files in the directory
-   and the convention that a file named `pandocomatic.yaml` in a
    directory is used as the *pandocomatic configuration file* to
    control the conversion of the files in that directory
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

Pandocomatic takes a number of arguments which at the least should
include the input file or directory. The general form of a pandocomatic
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
    `INPUT` and `--input` or `-i` cannot be used together.

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

    If you do not like this verbose behavior, use the `--quiet` or `-q`
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

A *pandocomatic configuration file* contains two sections:

1.  global `settings`
2.  external `templates`

These two sections are discussed after presenting an example of a
configuration file. For more in-depth information about pandocomatic
templates, please see the [Chapter on pandocomatic
templates](#pandocomatic-templates).

### Settings

You can configure four optional global settings:

1.  `data-dir`
2.  `skip`
3.  `recursive`
4.  `follow-links`

The latter three are used only when running pandocomatic to convert a
directory tree. These are discussed in the next sub section.

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
directory structure rather than to put everything together. For example,
a sub directory for processors, filters, CSL files, and pandoc templates
makes it easier to point to these assets.

#### Configuring converting a directory tree {#global-settings}

You can convert a directory tree with pandocomatic by invoking
pandocomatic with a directory as input rather than a file. Of course,
once you start converting directories, more fine-grained control over
what files to convert than "convert all files" is required. There are
four settings you can use to control which files to convert. Three of
them are global settings, the other one is the `glob` property of an
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
This default configuration is used whenever

-   no configuration is specified via the command-line option
    `--config`, and
-   no default configuration file (`pandocomatic.yaml`) can be found in
    the *pandocomatic data directory*.

When converting a directory tree, each time pandocomatic enters a
directory, it also looks for a default configuration file to *update*
the current settings. In other words, you can have pandocomatic behave
differently in a sub directory than the current directory by putting a
`pandocomatic.yaml` file in that sub directory that changes the global
settings or *external pandocomatic templates*.

### Templates

Besides the global `settings` section, a *pandocomatic configuration
file* can also contain a `templates` section. In the `templates` section
you define the *external pandocomatic templates* you want to use when
converting files with pandocomatic. Pandocomatic templates are discussed
in detail in the [Chapter on pandocomatic
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
will result in the following result"

    directory/
    + sub directory/
    | + index.html
    - index.html
    - image.png 

That is, all `.md` files are converted to HTML and all other files are
copied, recursively.

Pandocomatic templates
----------------------

Pandocomatic automates the use of pandoc by extracting common usage
patterns of pandoc into so called *pandocomatic templates*, which you
can then apply to your documents. As described in [Part
II](#using-pandocomatic), there are **internal** and **external**
*pandocomatic templates*. The difference between these two types of
templates is their scope: *internal pandocomatic templates* only affect
the document they are defined in, whereas *external pandocomatic
templates*, which are defined in a *pandocomatic configuration file*,
affect all documents that use that template.

Although you can create a one-off *internal pandocomatic template* for a
document—sometimes you just have an odd writing project that differs too
much from your regular writings—, most often you use an *external
pandocomatic template* and customize it in the *internal pandocomatic
template*.

In this Chapter the definition, extension, customization, and use of
templates are discussed in detail.

### Defining a template

An *external pandocomatic template* is defined in the `templates`
section of a *pandocomatic configuration file*. For example, in the
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

Each template is a YAML property in the `templates` section. The
property name is the template name. The property value is the template's
definition. A template definition can contain the following sections:

-   `extends`
-   `glob`
-   `setup`
-   `preprocessors`
-   `metadata`
-   `pandoc`
-   \`postprocessors'
-   `cleanup`

Before discussing these sections in detail, the way pandocomatic
resolves paths used in these sections is described first.

#### Specifying paths

Because templates can be used in any document, specifying paths to
assets to use in the conversion process is not straightforward. Using
global paths only could work, but has the disadvantage that the
templates are no longer shareable with others. Using local paths works
only if the assets and the document to convert are located in the same
directory. As a third alternative, pandocomatic also supports paths that
are relative to the *pandocomatic data directory*.

You can specify these types of paths as follows:

1.  All **local** paths start with a `./`. These paths are local to the
    document being converted. When converting a directory tree, the
    current directory is being prepended to the path minus the `./`.
2.  **global** paths start with a `/`. These paths are resolved as is.
3.  paths **relative** to the *pandocomatic data directory* do not start
    with a `./` nor a `/`. These paths are resolved by prepending the
    path to the *pandocomatic data directory*.

#### Template sections

##### `extends`

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
    configuration, this extension can be different from:

    ``` {.yaml}
    extends: ['overview', 'webpage']
    ```

##### `glob`

When a template is used for converting files in a directory tree, you
can specify which files in the directory should be converted by a
template. The `glob` section expects a list of [glob
patterns](http://ruby-doc.org/core-2.4.1/Dir.html#method-c-glob). All
files that match any of these glob patterns are converted using this
template.

When there are more templates that have matching glob patterns, the
first one is used.

If there is also a `skip` configured (see the [Section on global
settings](#global-settings), the `skip` setting has precedence of the
`glob` setting. Thus, if `skip` is `['*.md']` and `glob` is `['*.md']`,
the template will not be applied.

**Examples**

-   Apply this template to all files with extension `.md` (i.e. all
    markdown files):

    ``` {.yaml}
    glob: ['*.md']
    ```

-   Apply this template to all HTML files and all files starting with
    `overview_`:

    ``` {.yaml}
    glob: ['overview_*', '*.html']
    ```

##### `setup`

**Examples**

-   the example:

    ``` {.yaml}
    ```

##### `preprocessors`

**Examples**

-   the example:

    ``` {.yaml}
    ```

##### `metadata`

**Examples**

-   the example:

    ``` {.yaml}
    ```

##### `pandoc`

**Examples**

-   the example:

    ``` {.yaml}
    ```

##### `postprocessors`

**Examples**

-   the example:

    ``` {.yaml}
    ```

##### `cleanup`

**Examples**

-   the example:

    ``` {.yaml}
    ```

### Extending pandocomatic templates

### Extension rules

#### Simple values

#### Maps

#### Lists (or rather sets)

#### Modularity

### Customizing a template

#### `use-template`

#### Multiple conversions

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
    pandocomatic. It can contain the following sections:

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
    filters, postprocessors, setup scripts, and cleanup scripts.
    Defaults to pandoc's data directory.

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
