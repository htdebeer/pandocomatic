Pandocomatic—Automating the use of pandoc
=========================================

Pandocomatic is a tool to automate using [pandoc](http://pandoc.org/). With pandocomatic you can express common patterns of using pandoc for generating your documents. Applied to a directory, pandocomatic can act as a static site generator. For example, this manual and the website it is put on are generated using pandocomatic!

Why pandocomatic?
-----------------

I use [pandoc](http://pandoc.org/) a lot. I use it to write all my papers, notes, reports, outlines, summaries, and books. Time and again I was invoking pandoc like:

``` bash
pandoc --from markdown \
  --to html5 \
  --standalone \
  --csl apa.csl \
  --bibliography my-bib.bib \
  --mathjax \
  --output result.html \
  source.md
```

Sure, when I write about history, the csl file and bibliography changes. And I do not need the `--mathjax` option like I do when I am writing about mathematics education. Still, all these invocations are quite similar.

I already wrote the program *do-pandoc.rb* as part of a [Ruby](https://www.ruby-lang.org/en/) wrapper around pandoc, [paru](https://heerdebeer.org/Software/markdown/paru/). Using *do-pandoc.rb* I can specify the options to pandoc as pandoc metadata in the source file itself. The above pandoc invocation then becomes:

``` bash
do-pandoc.rb source.md
```

It saves me from typing out the whole pandoc invocation each time I run pandoc on a source file. However, I have still to setup the same options to use in each document that I am writing, even though these options do not differ that much from document to document.

*Pandocomatic* is a tool to re-use these common configurations by specifying a so-called *pandocomatic template* in a [YAML](http://yaml.org/) configuration file. For example, by placing the following file, `pandocomatic.yaml` in pandoc's data directory:

``` yaml
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

I now can create a new document that uses that configuration by using the following metadata in my source file, `on_teaching_maths.md`:

``` pandoc
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

To convert this file to `on_teaching_mathematics.html` I now run pandocomatic as follows:

``` bash
pandocomatic -i on_teaching_maths.md
```

With just two lines of pandoc metadata, I can tell pandocomatic what template to use when converting a file. Adding file-specific pandoc options to the conversion process is as easy as adding a `pandoc` property with those options to the `pandocomatic` metadata property in the source file.

Once I had written a number of related documents this way, it was a small step to enable pandocomatic to convert directories as well as files. Just like that, pandocomatic can be used as a *static site generator*!

Licence
-------

Pandocomatic is [free sofware](https://www.gnu.org/philosophy/free-sw.en.html); pandocomatic is released under the [GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html). You find pandocomatic's source code on [github](https://github.com/htdebeer/pandocomatic).

Installation
------------

Pandocomatic is installed through [RubyGems](https://rubygems.org/) as follows:

``` bash
gem install pandocomatic
```

You can also download the latest gem [pandocomatic-0.1.0](https://github.com/htdebeer/pandocomatic/blob/master/releases/pandocomatic-0.1.0.gem) from github and install it as follows:

``` bash
cd /directory/you/downloaded/the/gem/to
gem install pandocomatic-0.1.0.gem
```

Pandocomatic builds on [paru](https://heerdebeer.org/Software/markdown/paru/), a Ruby wrapper around pandoc, and [pandoc](http://pandoc.org/) itself, of course.

Examples
--------

Convert `hello.md` to `hello.html` according to the configuration in `pandocomatic.yaml`:

``` bash
pandocomatic --config pandocomatic.yaml -o hello.html -i hello.md
```

Generate a static site using data directory `assets`, but only convert files that have been updated since the last time pandocomatic has been run:

``` bash
pandocomatic --data-dir assets/ -o website/ -i source/ -m
```

More information
----------------

See [pandocomatic's manual](https://heerdebeer.org/Software/markdown/pandocomatic/) for more extensive examples of using pandocomatic. Notably, the manual contains two typical use cases of pandocomatic:

1.  automating setting up and running pandoc for a series of related papers and
2.  using pandocomatic as a static site generator.
