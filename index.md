---
author: Huub de Beer
date: 'March 1st, 2017'
keywords:
- pandoc
- ruby
- paru
- pandocomatic
- static site generator
pandocomatic-fileinfo:
  created: '2017-05-25'
  from: markdown
  modified: '2017-05-25'
  path: 'manual.md'
  to: markdown
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

Note that the pandocomatic YAML property is named `pandocomatic_`.
Pandoc has the
[convention](http://pandoc.org/MANUAL.html#metadata-blocks) that YAML
property names ending with an underscore will be ignored by pandoc and
can be used by programs like pandocomatic. Pandocomatic adheres to this
convention. However, for backwards compatibility the property name
`pandocomatic` still works, it just will not be ignored by pandoc.

Once I had written a number of related documents this way, it was a
small step to enable pandocomatic to convert directories as well as
files. Just like that, pandocomatic can be used as a *static site
generator*!

But more about that later. First, the installation of pandocomatic is
described, followed by its license. After that, in the next chapters,
using pandocomatic and configuring pandocomatic are described in detail.
The last two chapters of this manual describe two typical use cases of
pandocomatic:

1.  [automating setting up and running pandoc for a series of related
    papers](#automating-setting-up-and-running-pandoc-for-a-series-of-related-papers),
    and
2.  [using pandocomatic as a static site
    generator](#using-pandocomatic-as-a-static-site-generator).

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
[pandocomatic-0.1.4.16](https://github.com/htdebeer/pandocomatic/blob/master/releases/pandocomatic-0.1.4.16.gem)
from github and install it as follows:

``` {.bash}
cd /directory/you/downloaded/the/gem/to
gem install pandocomatic-0.1.4.16.gem
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

:   By default pandocomatic is quite verbose when you convert a
    directory. It tells you about the number of commands to execute.
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

:   Show the version. If this option is used, all other options are
    ignored.

`-h, --help`

:   Show a short help message. If this options is used, all other
    options except `--version` or `-v` are ignored.

2.1 Examples
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
pandocomatic -d data-dir -c config.yaml -i README.md -o ../README.md
pandocomatic -d data-dir -c config.yaml -i manual.md -o ../index.md
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
      - filters/insert_pandocomatic_version.rb
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
 pandocomatic_:
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
 
 1.  [automating setting up and running pandoc for a series of related papers](https://heerdebeer.org/Software/markdown/pandocomatic/#automating-setting-up-and-running-pandoc-for-a-series-of-related-papers), and 
 2.  [using pandocomatic as a static site
      generator](https://heerdebeer.org/Software/markdown/pandocomatic/#using-pandocomatic-as-a-static-site-generator).
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
pandocomatic_:
  use-template: mddoc
  pandoc:
    filter: 
    - 'filters/number_chapters_and_sections_and_figures.rb'
```

Pandocomatic allows you to generalize common aspects of running pandoc
while still offering the ability to be as specific as needed.

See Chapters
[4](#use-case-i-automating-setting-up-and-running-pandoc-for-a-series-of-related-papers)
and [5](#use-case-ii-use-pandocomatic-as-a-static-site-generator) for
more extensive examples on how to use pandocomatic.

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

Chapter 4. Automating setting up and running pandoc for a series of related papers {#automating-setting-up-and-running-pandoc-for-a-series-of-related-papers}
==================================================================================

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

Starting using pandoc
---------------------

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

Automating using pandocomatic
-----------------------------

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
    -   a **metadata block**,
    -   a **pandoc configuration**, and
    -   a list or **postprocessors**.

Applied to example of a series of related papers, a configuration file
could look like:

``` {.yaml}
templates:
  research-to-html:
    metadata:
      author: Huub de Beer
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

It would mix-in the metadata block in each and every file it converts
with the "research-to-html" template. As a result, all these files would
have set the author to my name.

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

#### Using a single pandocomatic template

I have saved the above `pandocomatic.yaml` file in my default data
directory. That directory also contains my postprocessors. Using the
*research-to-html* template is easy. Just put the following metadata
block in an input file:

``` {.yaml}
pandocomatic_:
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
pandocomatic_:
  use-template: research-to-html
  pandoc:
    output: draft_manuscript.html
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

Note that the pandocomatic YAML property is named `pandocomatic_`.
Pandoc has the
[convention](http://pandoc.org/MANUAL.html#metadata-blocks) that YAML
property names ending with an underscore will be ignored by pandoc and
can be used by programs like pandocomatic. Pandocomatic adheres to this
convention. However, for backwards compatibility the property name
`pandocomatic` still works, it just will not be ignored by pandoc.

### Using multiple pandocomatic templates

From pandocomatic version 0.1.13 onwards, pandocomatic supports using
more than one template. For each template used, a conversion is
performed. For example, assuming you have specified templates "web" and
"print", which convert an input markdown file to a HTML or PDF file
respectively, passing the following markdown file to pandocomatic will
generate two output files: a HTML and a PDF file!

``` {.pandoc}
 ---
 title: Using two templates
 pandocomatic_:
    use-template: 
    - web
    - print
 ...

 This file is **converted** to both:

 1. a HTML file
 2. a PDF file
```

The rules for multiple templates are the same as for using a single
template.

A common use case for using multiple templates is when generating a web
site. Alongside the generated HTML you can also generate a print-ready
PDF and link to it in the HTML file to boot.

Chapter 5. Using pandocomatic as a static site generator {#using-pandocomatic-as-a-static-site-generator}
========================================================

After explaining how pandocomatic can be used to automate setting up and
running pandoc for a series of related papers in the [previous
chapter](#automating-setting-up-and-running-pandoc-for-a-series-of-related-papers),
this chapter builds on that while elaborating how to use pandocomatic as
a static site generator. Once pandocomatic could automate the use of
pandoc to convert a file, it was a small step to allow pandocomatic
convert multiple files in a directory at once, recursively. The typical
use case for this feature is to generate a static web site from a
directory tree with sub directories and markdown files.

I learned to create web sites in the late 1990s. I learned how to write
HTML in a simple text editor and to freshen it up a bit with CSS. When I
got my own web server and domain on the internet, I wrote it by hand as
well. By that time I had learned all about content management systems
and dynamic web sites, but I liked the simplicity of expressing myself
in HTML. It was a bit more verbose than LaTeX for sure, but for a couple
of web pages that was fine. Once I started generating more content,
however, writing HTML became a hassle. Not in the least because updating
the layout of the site would mean updating all HTML files. As a result,
I stopped updating my web site but for the most necessary fixes and
additions.

In the meantime I had discovered pandoc, wrote a lot of papers and
documents in markdown, and started working on pandocomatic to automate
using pandoc to convert these documents. At that point it seemed only a
natural progression to convert these documents into a web site as well.
All I needed, really, was an HTML template for the web site's layout,
and then instruct pandoc to use that template while generating a
standalone HTML file. And then tell pandocomatic to do that for all
files in the source directory, recursively.

Configuring pandocomatic to convert a directory tree
----------------------------------------------------

The thing about generating a static site is that most input files are
converted using the same pandoc setup. Although a feature that allows
complete customization is great to have, and I have certainly used it in
a couple of times on my web site, pandocomatic allows you to configure a
default template, and to change that configuration for each sub
directory. But let see this in action.

My web site has the following directory structure, with left the source
input directory tree and right the output directory tree:

      /                             /
      + assets                      + assets
        + css                         + css
        + js                          + js
      + ALGOL                       + ALGOL
        - index.md                    - index.html
        - notation.md                 - notation.html
        - creation.md                 - creation.html  
        ...                           ...
      + DR                          + DR
        ...                           ...
      + Education                   + Education
        ...                           ...
      + History                     + History
        + ComputerPioneers            + ComputerPioneers
          ...                           ...
        -> ALGOL                      -> ALGOL
      + Software                    + Software
        + markdown                    + markdown
          + paru                        + paru
            - index.md                    - index.html
          + pandocomatic                + pandocomatic
            - index.md                    - index.html
        ...                           ...
      - about.md                    - about.html
      - publications.md             - publications.html
      - index.md                    - index.html

To generate my [website](https://heerdebeer.org), I use the following
command:

``` {.bash}
pandocomatic -c website-config.yaml -d data-dir -i src-tree -o www-tree
```

The configuration file `website-config.yaml` contains the following
configuration:

``` {.yaml}
settings:
    recursive: true
    follow-links: false
    skip: ['.*', 'pandocomatic.yaml']
templates:
    page:
        glob: ['*.markdown', '*.md']
        preprocessors: ['preprocessors/site_menu.rb']
        pandoc:
            from: markdown
            to: html5
            standalone: true
            template: 'templates/page.html'
            csl: 'apa.csl'
            toc: true
            mathjax: true
        postprocessors: ['postprocessors/tidy.sh']
```

Compared to the pandocomatic configuration files in the previous
chapter, a new property is added: **settings**. There are three settings
you can configure:

1.  **recursive**, which tells pandocomatic to also convert the sub
    directories in the current directory or not. The default value is
    `true`.
2.  **follow-links**, which tells pandocomatic to treat a symbolic link
    as its target, i.e., to follow a link. The default value is `false`,
    in which case pandocomatic tries to recreate a symbolic link in the
    output. In this example, the `ALGOL` link in the sub directory
    `History/` is recreated in the destintion tree.
3.  **skip**, a list of glob patterns of files and directories not to
    process with pandocomatic. By default *hidden files*, those starting
    with a period (`.`), and the *default pandocomatic configuration
    file* in a directory, `pandocomatic.yaml`, are skipped.

If you are happy with the [default
configuration](https://github.com/htdebeer/pandocomatic/blob/master/lib/pandocomatic/default_configuration.yaml),
there is no need to add these properties to your configuration files. If
you want to adapt the current configuration in a sub directory, you
create a `pandocomatic.yaml` file in that sub directory with different
settings or an other template. These new settings and templates are
merged with the current configuration.

*Note.* Currently it is not possible to "unskip" a glob pattern in a sub
directory. If you want to include an hidden file, for example, you're
out of luck. I do intend to add this in a future release.

Pandocomatic converts the input source tree to the output tree as
follows:

-   for each directory, read `pandocomatic.yaml` if any and merge the
    configuration in that file with the current configuration.
-   according to this new configuration, for each item in this
    directory:
-   ignore the item if it is matched by one of the glob patterns in the
    `skip` property, or
-   recreate all symbolic links that occur in the source tree in the
    destination tree if `follow-links` is false. Otherwise treat the
    links as a file or directory, or
-   if the item is a director:
    -   convert it following these steps if the setting `recursive` is
        true.
-   if the item is a file:
    -   convert all files that are matched by one of the glob patterns
        of any of the templates, or
    -   copy the file to the destination directory.

Using pandocomatic templates
----------------------------

Besides the *settings* property, there is a **templates** property in
the configuration file. This property is configured as explained in the
[previous chapter](#specifying-a-pandocomatic-template). The only
difference is the **glob** property. The *glob* property tells
pandocomatic to use this pandocomatic template to convert all files that
match one of the patterns. The first template with a pattern that is a
match for a source file will be used to convert that file.

Using this configuration, all markdown files recognized by their `.md`
or `.markdown` extension are converted to HTML using the pandoc custom
template `templates/page.html`, with a table of contents, references are
formatted according to APA, and to render mathematics the *mathjax*
library is used. This is the default pandoc configuration I use for most
of my files. The `tidy.sh` postprocessor is used to clean up the output
HTML and the
[`site_menu.rb`](https://github.com/htdebeer/pandocomatic/blob/master/documentation/data-dir/preprocessors/site_menu.rb)
preprocessor generates the site's menu. It adds the ancestral
directories as menu items into the source file's metadata, which are
rendered by the pandoc HTML template to render the menu on top of the
page.

Sometimes the default configuration is not suited to convert a file or a
directory of files. For example, the file in the directories that
contain my [historical papers](https://heerdebeer.org/History/) should
not use the APA CSL file to render references, but a style that is
common for historical publications like the *Chicago* style. It is easy
to extend a template. Just create a `pandocomatic.yaml` file in that
directory and reconfigure a template:

``` {.yaml}
templates:
    page:
        pandoc:
            csl: 'chicago-fullnote-bibliography.csl'
```

This works just like [extending templates in a source
file](https://heerdebeer.org/Software/markdown/pandocomatic/#using-a-pandocomatic-template).
If you want to change the template for one specific source file, you can
do so as well.

As you can see, using pandocomatic as a static site generator is
straightforward. Once you have created the initial setup, updating the
site is as easy as rerunning pandocomatic. In that case, the
`--modified-only` option is a great time saver as it only regenerates
those files that have been changed since the last time you generated
your web site.
