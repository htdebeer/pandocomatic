---
author: Huub de Beer
keywords:
- pandoc
- ruby
- paru
- pandocomatic
- static site generator
title: 'Pandocomatic—Automating the use of pandoc'
---

Chapter 1. Introduction {#introduction}
=======================

1.1 Why pandocomatic?
---------------------

I use [pandoc](http://pandoc.org/) a lot. I use it to write all my
papers, notes, reports, outlines, summaries, and books. Time and again I
was invoking pandoc like:

    pandoc --from markdown \
      --to html5 \
      --standalone \
      --csl apa.csl \
      --bibliography my-bib.bib \
      --mathjax \
      --output result.html \
      source.md

Sure, when I write about history, the csl file and bibliography changes.
And I do not need the `--mathjax` option like I do when I am writing
about mathematics education. Still, all these invocations are quite
similar.

I already wrote the program *do-pandoc.rb* as part of a
[Ruby](https://www.ruby-lang.org/en/) wrapper around pandoc,
[paru](https://heerdebeer.org/Software/markdown/paru/). Using
*do-pandoc.rb* I can specify the options to pandoc as pandoc metadata in
the source file itself. The above pandoc invocation then becomes:

    do-pandoc.rb source.md

It saves me from typing out the whole pandoc invocation each time I run
pandoc on a source file. However, I have still to setup the same options
to use in each document that I am writing, even though these options do
not differ that much from document to document.

*Pandocomatic* is a tool to re-use these common configurations by
specifying a so-called *pandocomatic template* in a
[YAML](http://yaml.org/) configuration file. For example, by placing the
following file, `pandocomatic.yaml` in pandoc's data directory:

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

I now can create a new document that uses that configuration by using
the following metadata in my source file, `on_teaching_maths.md`:

    ---
    title: On teaching mathematics
    author: Huub de Beer
    pandocomatic:
      use-template: education-research
      pandoc:
        output: on_teaching_mathematics.html
    ...

    and here follows the contents of my new paper...

To convert this file to `on_teaching_mathematics.html` I now run
pandocomatic as follows:

    pandocomatic -i on_teaching_maths.md

With just two lines of pandoc metadata, I can tell pandocomatic what
template to use when converting a file. Adding file-specific pandoc
options to the conversion process is as easy as adding a `pandoc`
property with those options to the `pandocomatic` metadata property in
the source file.

Once I had written a number of related documents this way, it was a
small step to enable pandocomatic to convert directories as well as
files. Just like that, pandocomatic can be used as a *static site
generator*!

1.2 Licence
-----------

gplv3

1.3 Installation
----------------
