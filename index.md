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

Chapter 1. Introduction {#introduction}
=======================

Pandocomatic is a tool to automate using [pandoc](http://pandoc.org/).
With pandocomatic you can express common patterns of using pandoc for
generating your documents. Applied to a directory, pandocomatic can act
as a static site generator. For example, this manual and the website it
is put on are generated using pandocomatic!

1.1 Why pandocomatic?
---------------------

I use [pandoc](http://pandoc.org/) a lot. I use it to write all my
papers, notes, websites, reports, outlines, summaries, and books. Time
and again I was invoking pandoc like:

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
file and bibliography changes. And I do not need the `--mathjax` option
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

1.2 Licence
-----------

Pandocomatic is [free
sofware](https://www.gnu.org/philosophy/free-sw.en.html); pandocomatic
is released under the
[GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html). You find
pandocomatic's source code on
[github](https://github.com/htdebeer/pandocomatic).

1.3 Installation
----------------

Pandocomatic is installed through [RubyGems](https://rubygems.org/) as
follows:

``` {.bash}
gem install pandocomatic
```

You can also download the latest gem
[pandocomatic-0.1.1](https://github.com/htdebeer/pandocomatic/blob/master/releases/pandocomatic-0.1.1.gem)
from github and install it as follows:

``` {.bash}
cd /directory/you/downloaded/the/gem/to
gem install pandocomatic-0.1.1.gem
```

Pandocomatic builds on
[paru](https://heerdebeer.org/Software/markdown/paru/), a Ruby wrapper
around pandoc, and [pandoc](http://pandoc.org/) itself, of course.

Chapter 2. Using pandocomatic {#using-pandocomatic}
=============================

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

2.1 Required arguments
----------------------

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

2.2 Optional arguments
----------------------

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

2.3 Examples
------------

### Convert a single file

Convert `hello.md` to `hello.html` according to the configuration in
`pandocomatic.yaml`:

``` {.bash}
pandocomatic --config pandocomatic.yaml -o hello.html -i hello.md
```

### Convert a directory

Generate a static site using data directory `assets`, but only convert
files that have been updated since the last time pandocomatic has been
run:

``` {.bash}
pandocomatic --data-dir assets/ -o website/ -i source/ -m
```

### Generating pandocomatic's manual and README files

Generate the markdown files for pandocomatic's
[manual](https://heerdebeer.org/Software/markdown/pandocomatic/) and its
[github repository](https://github.com/htdebeer/pandocomatic) README:

``` {.bash}
git clone https://github.com/htdebeer/pandocomatic.git
cd documentation
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
`insert_code_block.rb`, and `remove_pandocomatic_metadata.rb`. The first
two filters allow you to include another markdown file or to include a
source code file (see the README listing below). The last filter removes
the pandocomatic metadata block from the file so the settings in it do
not interfere when, later on, `manual.md` is converted to HTML. These
filters are located in the
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

Similarly, in the input file
[`manual.md`](https://github.com/htdebeer/pandocomatic/blob/master/documentation/manual.md),
an extra filter is specified,
['number\_chapters\_and\_sections\_and\_figures.rb'](https://github.com/htdebeer/pandocomatic/blob/master/documentation/data-dir/filters/number_chapters_and_sections_and_figures.rb),
to number the chapters and sections in the manual, which is not needed
for the README, by using the following pandocomatic metadata in the
manual input file:

``` {.yaml}
pandocomatic:
  use-template: mddoc
  pandoc:
    filter: 
    - 'filters/number_chapters_and_sections_and_figures.rb'
```

Pandocomatic allows you to generalize common aspects of running pandoc
while still offering the ability to be as specific as needed.

See Chapters 4 & 5 for more extensive examples of using pandocomatic.

In the next chapter the configuration of pandocomatic is elaborated.

Chapter 3. Configuring pandocomatic {#configuring-pandocomatic}
===================================

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

Chapter 4. Use case I: Automating setting up and running pandoc for a series of related papers {#use-case-i-automating-setting-up-and-running-pandoc-for-a-series-of-related-papers}
==============================================================================================

4.1 Introduction
----------------

In this chapter I will elaborate on the example from the
[Introduction](#why-pandocomatic) about using pandocomatic to configure
and run pandoc for a series of related research papers.

In 2010 I started a PhD project in mathematics education on [exploring
instantaneous speed in grade 5](https://heerdebeer.org/DR/). Before I
started this project I used [LaTeX](https://www.latex-project.org/) for
all my writings in history, computer science, science education, and
also to create educational materials I used when I taught computer
science in high school. I like LaTeX, in particular because of its
readable plain text formal and the ability to create my own commands and
environments. And so long as I was writing papers for print, I could not
think of better tool for me.

However, times were changing and print became more and more a secondary
output format. The web took precedence. Generating a well-formatted HTML
page from a LaTeX source document appeared harder than it ought to be. I
tried tools like [latex2html](http://www.latex2html.org/) and
[tex4ht](https://tug.org/applications/tex4ht/mn.html), but it was always
a hassle to use and the output not that great.

Meanwhile I started collaborating on papers. Most of of my colleagues
had not heard of LaTeX, and, to be honest, why would they care? I was
the one using "odd software" in my field and even if I could convince
them to go the LaTeX route, the frustration that would cause is not
worth the trouble. In the end writing is about *writing* not about tools
or processes.

Still, I did not want to give up on my workflow either: I like working
with plain text with tools like [vim](http://www.vim.org/), version
control, [grep](https://www.gnu.org/software/grep/), and so on. I went
looking for a tool that would allow me keep my workflow, enabled me to
collaborate with people using [Microsoft
Word](https://products.office.com/en/word), and would generate both
print and HTML. I found [pandoc](http://pandoc.org) version 1.5 and I
have been using it for all my writings since then.

4.2 Starting using pandoc
-------------------------

Using pandoc is quite straightforward. At the least, you need to specify
the input format, the output format, the input file, and the output
file. The conversion process can be influenced by a whole range of
[command line options](http://pandoc.org/MANUAL.html#options). You can
choose to generate a table of contents, render mathematics, an output
template to use, and so on.

Usually, when starting a new paper I create a new directory and put in
it one or more pandoc markdown files that comprise the contents of the
paper. Then, when I want to read the paper as it is now, I convert it
through pandoc with a command similar to:

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

Every time I want to see how the changes look, I have to re-run the
command. Even though I can use
[bash's](https://www.gnu.org/software/bash/) command history feature, it
gets old fast. Particularly because I was writing multiple papers at
once on different machines.

To prevent me from entering the same command over and over, I created a
pandoc wrapper written in Ruby,
[paru](https://heerdebeer.org/Software/markdown/paru/), to write a
script with it called `do-pandoc.rb`. Now I could specify the pandoc
configuration in a YAML metadata block in the input file and convert it
by running `do-pandoc.rb`. After introducing this script, on whatever
machine I was working, on whatever paper I was working, invoking pandoc
did not get more complicated than:

``` {.bash}
do-pandoc.rb source.md
```

Great!

If I wanted a different output format, most often `docx`, to send a new
version of a manuscript to my colleagues who were using Microsoft Word,
just changing the pandoc configuration temporarily and running
`do-pandoc.rb` would not always work well. I had to change more options
or I had to run pandoc manually all over again for this different output
format.

Furthermore, over time, I found that when I started a new paper I would
copy the source file of an old paper, change the title, keywords, and
date, and removed the content to start afresh. The metadata with the
pandoc setup would be the same except for the output file, that I would
change to fit the new paper.

Not a problem if you only write a paper now and then, but while I was
doing my PhD, I found I was creating a lot of papers, outlines,
proposals, course materials, pamphlets, presentations, overviews,
etcetera. All more or less using the same pandoc configuration. I always
had to think about which paper's configuration to copy for a particular
new paper, and if I made some improvements on the configuration, like a
new template or an option that I discovered I liked, I always was
conflicted if I would update previous configurations as well.

Finally, sometimes I would apply a script to either the input file or
the output. For example, I would run [tidy](http://www.html-tidy.org/)
to clean up HTML output. Or I would run
[linkchecker](https://wummel.github.io/linkchecker/) to check that all
links in the output point to something. Again, it is no problem to run
these scripts now and then, but if you are running them all the time it
becomes a hassle

To improve upon this situation I created pandocomatic.

4.3 Automating using pandocomatic
---------------------------------

The basic concepts underlying pandocomatic are *templates* that contain
a *pandoc configuration*, a list of *preprocessors*, and a list of
*postprocessors*. These named templates can be *used* in a pandoc
markdown input file and customized to fit a particular use case for that
template.

### Preprocessors and postprocessors

The preprocessors and postprocessors are run before and after pandoc is
invoked on an input file. For example, I prefer a cleaner HTML output
than pandoc generates and I like to check that all my links in the
generated HTML work. I have created simple shell scripts for these
tasks. For running `tidy` that script looks like:

``` {.bash}
#!/bin/bash
tidy -quiet -clean -indent -wrap 78 -utf8
```

For running `linkchecker` that script is slightly more involved because
it does not read a HTML file from standard input, nor does it write that
file to standard output like `tidy` does:

``` {.bash}
#!/bin/bash
INPUT=`cat`
file_to_check="/tmp/FILE_TO_LINK_CHECK.html"
echo "$INPUT" > $file_to_check
linkchecker --no-status --anchors --check-extern $file_to_check 1>&2
cat $file_to_check
```

The important thing to remember about processors is that they read from
standard input and write to standard output. Ensure that all output from
these scripts that you do not want to end up in the final result is not
printed to standard output.

### Specifying a pandocomatic template

Specifying a template is easy:

-   create a configuration YAML file, say `pandocomatic.yaml`
-   add a **templates** property, and for each template:
    -   add the template's **name** as a property containing:
    -   a list of **preprocessors**,
    -   a **pandoc configuration**, and
    -   a list or **postprocessors**.

Applied to example of a series of related papers, a configuration file
could look like:

``` {.yaml}
templates:
  research-to-html:
    pandoc:
      from: markdown
      to: html5
      standalone: true
      toc: true
      csl: 'apa.csl'
      bibliography: '~/Documents/bibliography.bib'
    postprocessors:
      - 'postprocessors/tidy.sh'
      - 'postprocessors/linkchecker.sh'
```

For paths in a template, such as for the CSL file, bibliography, and
postprocessors, are looked up according to the following rules:

-   if a path starts with a period ("."), the path is relative to the
    file being converted.
-   if a path starts with a slash ("/"), the path is an absolute path
-   if a path starts with neither a period or a slash, the path is
    relative to the data directory.

If no **data directory** is specified when invoking pandocomatic,
pandoc's data directory is used as the default data directory. Run the
command

``` {.bash}
pandoc --version
```

to find out what that data directory is on your system. On mine it is
`~/.pandoc`.

It is good practice to create a separate `filters`, `preprocessors`, and
`postprocessors` sub directory in your data directory.

If no configuration file is specified when invoking pandocomatic,
pandocomatic tries to find one named **`pandocomatic.yaml`** in the
current working directory or, if there is no such file, the data
directory and then the default data directory.

### Using a pandocomatic template

I have saved the above `pandocomatic.yaml` file in my default data
directory. That directory also contains my postprocessors. Using the
*research-to-html* template is easy. Just put the following metadata
block in an input file:

``` {.yaml}
pandocomatic:
  use-template: research-to-html
```

To generate a HTML file from the input file, run pandocomatic:

``` {.bash}
pandocomatic --input paper.md --output draft_manuscript.html
```

If you write your output to the same file each time you convert the
input file, you can **extend** the template in the input file as
follows:

``` {.yaml}
pandocomatic:
  use-template: research-to-html
  pandoc:
    to: draft_manuscript.html
```

Running pandocomatic becomes even simpler:

``` {.bash}
pandocomatic paper.md
```

That is it!

You can extend the preprocessors used, the postprocessors used, and all
pandoc options. Changing certain options does not make always sense. In
this example, changing the `to` option to `docx` will get you in
trouble. Pandoc will run fine, but when the postprocessors are run on
the outputted docx file, things will get awry.

No problem, though, for you can add a second template to your
configuration file that generates docx files. For example:

``` {.yaml}
templates:
  research-to-docx:
    pandoc:
      from: markdown
      to: docx
      toc: true
      csl: 'apa.csl'
      bibliography: '~/Documents/bibliography.bib'
      reference-docx: 'apa-formatted-paper.docx'
  research-to-html:
    pandoc:
      from: markdown
      to: html5
      standalone: true
      toc: true
      csl: 'apa.csl'
      bibliography: '~/Documents/bibliography.bib'
    postprocessors:
      - 'postprocessors/tidy.sh'
      - 'postprocessors/linkchecker.sh'
```

Just change the used template in your input file to `research-to-docx`
and run pandocomatic to generate a Microsoft Word file I can share with
my colleagues. If the reference docx from the template is not
sufficient, journals like to use slightly different styles after all,
you can extend the template in your input file. No problem.

Using pandocomatic has simplified my workflow for writing papers with
pandoc significantly. Over the years, I have collected a set of
templates, preprocessors, postprocessors, and filters I use over and
over.

Chapter 5. Use case II: Use pandocomatic as a static site generator {#use-case-ii-use-pandocomatic-as-a-static-site-generator}
===================================================================

to be done
