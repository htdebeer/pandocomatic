---
author: Huub de Beer
date: 'September 21st, 2017'
keywords:
- pandoc
- ruby
- paru
- pandocomatic
- static site generator
pandocomatic-fileinfo:
  created: '2017-09-16'
  from: markdown
  modified: '2017-09-16'
  path: 'manual2.md'
  to: markdown
subtitle: Automating the use of pandoc
title: Pandocomatic
---

Chapter 1. Introduction {#introduction}
=======================

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
[pandocomatic-0.1.4.17](https://github.com/htdebeer/pandocomatic/blob/master/releases/pandocomatic-0.1.4.17.gem)
from [Github](https://github.com) and install it manually as follows:

``` {.bash}
cd /directory/you/downloaded/the/gem/to
gem install pandocomatic-0.1.4.17.gem
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

Chapter 2. Using pandocomatic: Quick start and overview {#using-pandocomatic-quick-start-and-overview}
=======================================================

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

Chapter 3. Reference: All about pandocomatic {#reference-all-about-pandocomatic}
============================================

Pandocomatic command-line interface {#pandocomatic-cli}
-----------------------------------

Pandocomatic templates
----------------------

Note that the pandocomatic YAML property is named `pandocomatic_`.
Pandoc has the
[convention](http://pandoc.org/MANUAL.html#metadata-blocks) that YAML
property names ending with an underscore will be ignored by pandoc and
can be used by programs like pandocomatic. Pandocomatic adheres to this
convention. However, for backwards compatibility the property name
`pandocomatic` still works, it just will not be ignored by pandoc.

### Extending pandocomatic templates

### Specifying paths

------------------------------------------------------------------------

Chapter 4. Appendix {#appendix}
===================

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
