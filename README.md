[![Gem
Version](https://badge.fury.io/rb/pandocomatic.svg)](https://badge.fury.io/rb/pandocomatic)

# Pandocomatic—Automate the use of pandoc

Pandocomatic is a tool to automate the use of
[pandoc](https://pandoc.org/). With pandocomatic you can express common
patterns of using pandoc for generating your documents. Applied to a
directory, pandocomatic can act as a static site generator. For example,
this manual is generated with pandocomatic\!

Pandocomatic is [free
software](https://www.gnu.org/philosophy/free-sw.en.html); pandocomatic
is released under the
[GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html). You will find the
source code of pandocomatic in its
[repository](https://github.com/htdebeer/pandocomatic) on
[Github](https://github.com).

See [pandocomatic’s
manual](https://heerdebeer.org/Software/markdown/pandocomatic/) for an
extensive description of pandocomatic.

## Why pandocomatic?

I use pandoc a lot. I use it to write all my papers, notes, websites,
reports, outlines, summaries, and books. Time and again I was invoking
pandoc like:

``` bash
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

``` bash
do-pandoc.rb source.md
```

It saves me from typing out the whole pandoc invocation each time I run
pandoc on a source file. However, I have still to setup the same options
to use in each document that I am writing, even though these options do
not differ that much from document to document.

*Pandocomatic* is a tool to re-use these common configurations by
specifying a so-called *pandocomatic template* in a
[YAML](https://yaml.org/) configuration file. For example, by placing
the following file, `pandocomatic.yaml`, in pandoc’s data directory:

``` yaml
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
source files are converted with pandoc by invoking `pandoc --from
markdown --to html --standalone --csl apa.csl --toc --bibliography
/path/to/bibliography.bib --mathjax`. Finally, the template specifies
that pandoc’s output is not being postprocessed.

I now can create a new document that uses this template by including the
following metadata block in my source file, `on_teaching_maths.md`:

``` pandoc
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

``` bash
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
like that, pandocomatic can be used as a *static site generator*\!

Pandocomatic is [free
software](https://www.gnu.org/philosophy/free-sw.en.html); pandocomatic
is released under the
[GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html). You find
pandocomatic’s source code on
[github](https://github.com/htdebeer/pandocomatic).

## Installation

Pandocomatic is a [Ruby](https://www.ruby-lang.org/en/) program and can
be installed through [RubyGems](https://rubygems.org/) as follows:

``` bash
gem install pandocomatic
```

This will install pandocomatic and
[paru](https://heerdebeer.org/Software/markdown/paru/), a Ruby wrapper
around pandoc. To use pandocomatic, you also need a working pandoc
installation. See [pandoc’s installation
guide](https://pandoc.org/installing.html) for more information about
installing pandoc.

You can also download the latest gem,
[pandocomatic-0.2.5.4](https://github.com/htdebeer/pandocomatic/blob/master/releases/pandocomatic-0.2.5.4.gem),
from Github and install it manually as follows:

``` bash
cd /directory/you/downloaded/the/gem/to
gem install pandocomatic-0.2.5.4.gem
```

## Examples

### Convert a single file

Convert `hello.md` to `hello.html` according to the configuration in
`pandocomatic.yaml`:

``` bash
pandocomatic --config pandocomatic.yaml -o hello.html -i hello.md
```

### Convert a directory

Generate a static site using data directory `assets`, but only convert
files that have been updated since the last time pandocomatic has been
run:

``` bash
pandocomatic --data-dir assets/ -o website/ -i source/ -m
```

### Generating pandocomatic’s manual and README files

Generate the markdown files for pandocomatic’s
[manual](https://heerdebeer.org/Software/markdown/pandocomatic/) and its
[github repository](https://github.com/htdebeer/pandocomatic) README:

``` bash
git clone https://github.com/htdebeer/pandocomatic.git
cd documentation
pandocomatic -d data-dir -c config.yaml -i README.md -o ../README.md
pandocomatic -d data-dir -c config.yaml -i manual.md -o ../index.md
```

Be careful to not overwrite the input file with the output file\! I
would suggest using different names for both, or different directories.
Looking more closely to the pandocomatic configuration file
`config.yaml`, we see it contains one template, `mddoc`:

``` yaml
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
   indexdoc:
       extends: mddoc
       postprocessors: ['postprocessors/setup_for_website.rb']
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

However, the `mddoc` template converts from and to pandoc’s markdown
variant, which differs slightly from the markdown variant used by
[Github](https://github.com/) for README files. Luckily, pandoc does
support writing Github’s markdown variant. There is no need to create
and use a different template for generating the README, though, as you
can override all template’s settings inside a pandocomatic block in a
markdown file:

``` markdown
 ---
 pandocomatic_:
   use-template: mddoc
   pandoc:
     to: markdown_github
 ...
 
 # Pandocomatic—Automate the use of pandoc
 
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
[‘number\_chapters\_and\_sections\_and\_figures.rb’](https://github.com/htdebeer/pandocomatic/blob/master/documentation/data-dir/filters/number_chapters_and_sections_and_figures.rb),
to number the chapters and sections in the manual, which is not needed
for the README, by using the following pandocomatic metadata in the
manual input file:

``` yaml
pandocomatic_:
  use-template: mddoc
  pandoc:
    filter: 
    - 'filters/number_chapters_and_sections_and_figures.rb'
```

Pandocomatic allows you to generalize common aspects of running pandoc
while still offering the ability to be as specific as needed.

## More information

See [pandocomatic’s
manual](https://heerdebeer.org/Software/markdown/pandocomatic/) for more
extensive examples of using pandocomatic.
