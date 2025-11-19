## Why pandocomatic?

I use pandoc a lot. I use it to write all my papers, notes, websites, reports,
outlines, summaries, and books. Time and again I was invoking pandoc like: 

~~~{.bash}
pandoc --from markdown \
  --to html \
  --standalone \
  --csl apa.csl \
  --bibliography my-bib.bib \
  --mathjax \
  --output result.html \
  source.md
~~~

Sure, when I write about history, the [CSL](https://citationstyles.org/) file
and bibliography change. And I do not need the `--mathjax` option like I do
when I am writing about mathematics education. Still, all these invocations
are quite similar.
  
I already wrote the program *do-pandoc.rb* as part of a Ruby wrapper around
pandoc, [paru](https://heerdebeer.org/Software/markdown/paru/). Using
*do-pandoc.rb* I can specify the options to pandoc in a metadata block in the
source file itself. With *do-pandoc.rb* you simplify the invocation above to:

~~~{.bash}
do-pandoc.rb source.md
~~~

It saves me from typing out the pandoc invocation each time I run pandoc on a
source file. However, I have still to set up the same options to use in each
document that I am writing, even though these options do not differ that much
from document to document.

*Pandocomatic* is a tool to re-use these common configurations by specifying a
so-called *pandocomatic template* in a [YAML](https://yaml.org/) configuration
file. For example, by placing the following file, `pandocomatic.yaml`, in
pandoc's data directory:

~~~{.yaml}
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
~~~   

In this configuration file I define a single *pandocomatic template*:
*education-research*. This template specifies that the source files it is
applied to are not being preprocessed. Furthermore, the source files are
converted with pandoc by invoking `pandoc --from markdown --to html
--standalone --csl apa.csl --toc --bibliography /path/to/bibliography.bib
--mathjax`.  Finally, the template specifies that pandoc's output is not being
postprocessed.

I now can create a new document that uses this template by including the
following metadata block in my source file, `on_teaching_maths.md`:

~~~{.pandoc}
 ---
 title: On teaching mathematics
 author: Huub de Beer
 pandocomatic_:
   use-template: education-research
   pandoc:
     output: on_teaching_mathematics.html
 ...
 
 Here goes the contents of my new paper ...
~~~
    
To convert this file to `on_teaching_mathematics.html` I run pandocomatic:

~~~{.bash}   
pandocomatic -i on_teaching_maths.md
~~~

With just two extra lines in a metadata block I can tell pandocomatic what
template to use when converting a file. You can also use multiple templates in
a document, for example to convert a markdown file to both HTML and PDF.
Adding file-specific pandoc options to the conversion process is as easy as
adding a `pandoc` property with those options to the `pandocomatic_` metadata
property in the source file like I did with the `output` property in the
example above. 

Alternatively, you can use pandocomatic's `--template` command-line option and
skip the `pandocomatic_` metadata block in your source file or use
pandocomatic with non-markdown source files. In this example, run
pandocomatic:

~~~{.bash}
pandocomatic -i on_teaching_maths.md --template education-research
~~~

Once I had written several related documents this way, it was a small step to
enable pandocomatic to convert directories as well. Just like that,
pandocomatic can be used as a *static site generator*!
