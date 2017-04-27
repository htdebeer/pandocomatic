I use [pandoc](http://pandoc.org/) a lot. I use it to write all my papers,
notes, websites, reports, outlines, summaries, and books. Time and again I was
invoking pandoc like: 

~~~{.bash}
pandoc --from markdown \
  --to html5 \
  --standalone \
  --csl apa.csl \
  --bibliography my-bib.bib \
  --mathjax \
  --output result.html \
  source.md
~~~

Sure, when I write about history, the [CSL](http://citationstyles.org/) file
and bibliography changes. And I do not need the `--mathjax` option like I do
when I am writing about mathematics education. Still, all these invocations
are quite similar. 
  
I already wrote the program *do-pandoc.rb* as part of a
[Ruby](https://www.ruby-lang.org/en/) wrapper around pandoc,
[paru](https://heerdebeer.org/Software/markdown/paru/). Using *do-pandoc.rb* I
can specify the options to pandoc as pandoc metadata in the source file
itself. The above pandoc invocation then becomes:

~~~{.bash}
do-pandoc.rb source.md
~~~

It saves me from typing out the whole pandoc invocation each time I run pandoc
on a source file. However, I have still to setup the same options to use in
each document that I am writing, even though these options do not differ that
much from document to document.

*Pandocomatic* is a tool to re-use these common configurations by specifying a
so-called *pandocomatic template* in a [YAML](http://yaml.org/) configuration
file. For example, by placing the following file, `pandocomatic.yaml` in
pandoc's data directory:

~~~{.yaml}
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
~~~    

I now can create a new document that uses that configuration by using the
following metadata in my source file, `on_teaching_maths.md`:

~~~{.pandoc}
---
title: On teaching mathematics
author: Huub de Beer
pandocomatic_:
  use-template: education-research
  pandoc:
    output: on_teaching_mathematics.html
...

and here follows the contents of my new paper...
~~~
    
To convert this file to `on_teaching_mathematics.html` I now run pandocomatic
as follows:

~~~{.bash}   
pandocomatic -i on_teaching_maths.md
~~~

With just two lines of pandoc metadata, I can tell pandocomatic what template
to use when converting a file. Adding file-specific pandoc options to the
conversion process is as easy as adding a `pandoc` property with those options
to the `pandocomatic_` metadata property in the source file. 

Note that the pandocomatic YAML property is named `pandocomatic_`. Pandoc has
the [convention](http://pandoc.org/MANUAL.html#metadata-blocks) that YAML
property names ending with an underscore will be ignored by pandoc and can be
used by programs like pandocomatic. Pandocomatic adheres to this convention.
However, for backwards compatibility the property name `pandocomatic` still
works, it just will not be ignored by pandoc.

Once I had written a number of related documents this way, it was a small step
to enable pandocomatic to convert directories as well as files. Just like
that, pandocomatic can be used as a *static site generator*! 
