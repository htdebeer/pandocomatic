In this chapter I will elaborate on the example from the
[Introduction](#why-pandocomatic) about using pandocomatic to configure and
run pandoc for a series of related research papers.

In 2010 I started a PhD project in mathematics education on [exploring
instantaneous speed in grade 5](https://heerdebeer.org/DR/). Before I started
this project I used [LaTeX](https://www.latex-project.org/) for all my
writings in history, computer science, science education, and also to create
educational materials I used when I taught computer science in high school. I
like LaTeX, in particular because of its readable plain text formal and the
ability to create my own commands and environments. And so long as I was
writing papers for print, I could not think of better tool for me.

However, times were changing and print became more and more a secondary output
format. The web took precedence. Generating a well-formatted HTML page from a
LaTeX source document appeared harder than it ought to be. I tried tools like
[latex2html](http://www.latex2html.org/) and
[tex4ht](https://tug.org/applications/tex4ht/mn.html), but it was always a
hassle to use and the output not that great. 

Meanwhile I started collaborating on papers. Most of of my colleagues had not
heard of LaTeX, and, to be honest, why would they care? I was the one using
"odd software" in my field and even if I could convince them to go the LaTeX
route, the frustration that would cause is not worth the trouble. In the end
writing is about *writing* not about tools or processes.

Still, I did not want to give up on my workflow either: I like working with
plain text with tools like [vim](http://www.vim.org/), version control,
[grep](https://www.gnu.org/software/grep/), and so on. I went looking for a
tool that would allow me keep my workflow, enabled me to collaborate with
people using [Microsoft Word](https://products.office.com/en/word), and would
generate both print and HTML. I found [pandoc](http://pandoc.org) version 1.5
and I have been using it for all my writings since then.

## Starting using pandoc

Using pandoc is quite straightforward. At the least, you need to specify the
input format, the output format, the input file, and the output file. The
conversion process can be influenced by a whole range of [command line
options](http://pandoc.org/MANUAL.html#options). You can choose to generate a
table of contents, render mathematics, an output template to use, and so on.

Usually, when starting a new paper I create a new directory and put in it one
or more pandoc markdown files that comprise the contents of the paper. Then,
when I want to read the paper as it is now, I convert it through pandoc with a
command similar to:

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

Every time I want to see how the changes look, I have to re-run the command.
Even though I can use [bash's](https://www.gnu.org/software/bash/) command
history feature, it gets old fast. Particularly because I was writing multiple
papers at once on different machines.

To prevent me from entering the same command over and over, I created a pandoc
wrapper written in Ruby,
[paru](https://heerdebeer.org/Software/markdown/paru/), to write a script with
it called `do-pandoc.rb`. Now I could specify the pandoc configuration in a
YAML metadata block in the input file and convert it by running
`do-pandoc.rb`. After introducing this script, on whatever machine I was
working, on whatever paper I was working, invoking pandoc did not get more
complicated than:

~~~{.bash}
do-pandoc.rb source.md
~~~

Great! 

If I wanted a different output format, most often `docx`, to send a new
version of a manuscript to my colleagues who were using Microsoft Word, just
changing the pandoc configuration temporarily and running `do-pandoc.rb` would
not always work well. I had to change more options or I had to run pandoc
manually all over again for this different output format.

Furthermore, over time, I found that when I started a new paper I would copy
the source file of an old paper, change the title, keywords, and date, and
removed the content to start afresh. The metadata with the pandoc setup would
be the same except for the output file, that I would change to fit the new
paper. 

Not a problem if you only write a paper now and then, but while I was doing my
PhD, I found I was creating a lot of papers, outlines, proposals, course
materials, pamphlets, presentations, overviews, etcetera. All more or less
using the same pandoc configuration. I always had to think about which paper's
configuration to copy for a particular new paper, and if I made some
improvements on the configuration, like a new template or an option that I
discovered I liked, I always was conflicted if I would update previous
configurations as well. 

Finally, sometimes I would apply a script to either the input file or the
output. For example, I would run [tidy](http://www.html-tidy.org/) to clean up
HTML output. Or I would run
[linkchecker](https://wummel.github.io/linkchecker/) to check that all links
in the output point to something. Again, it is no problem to run these scripts
now and then, but if you are running them all the time it becomes a hassle

To improve upon this situation I created pandocomatic.

## Automating using pandocomatic

The basic concepts underlying pandocomatic are *templates* that contain a
*pandoc configuration*, a list of *preprocessors*, and a list of
*postprocessors*. These named templates can be *used* in a pandoc markdown
input file and customized to fit a particular use case for that template. 

### Preprocessors and postprocessors

The preprocessors and postprocessors are run before and after pandoc is
invoked on an input file. For example, I prefer a cleaner HTML output than
pandoc generates and I like to check that all my links in the generated HTML
work. I have created simple shell scripts for these tasks. For running `tidy`
that script looks like:

~~~{.bash}
::paru::insert data-dir/postprocessors/tidy.sh
~~~

For running `linkchecker` that script is slightly more involved because it
does not read a HTML file from standard input, nor does it write that file to
standard output like `tidy` does:

~~~{.bash}
::paru::insert data-dir/postprocessors/linkchecker.sh
~~~

The important thing to remember about processors is that they read from
standard input and write to standard output. Ensure that all output from these
scripts that you do not want to end up in the final result is not printed to
standard output.

### Specifying a pandocomatic template

Specifying a template is easy:

-   create a configuration YAML file, say `pandocomatic.yaml`
-   add a **templates** property, and for each template:
    -   add the template's **name** as a property containing:
    -   a list of **preprocessors**,
    -   a **pandoc configuration**, and
    -   a list or **postprocessors**.

Applied to example of a series of related papers, a configuration file could
look like:

~~~{.yaml}
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
~~~

For paths in a template, such as for the CSL file, bibliography, and postprocessors, are looked up according to the following rules:

- if a path starts with a period ("."), the path is relative to the file being
  converted.
- if a path starts with a slash ("/"), the path is an absolute path
- if a path starts with neither a period or a slash, the path is relative to
  the data directory.

If no **data directory** is specified when invoking pandocomatic, pandoc's
data directory is used as the default data directory. Run the command

~~~{.bash}
pandoc --version
~~~

to find out what that data directory is on your system. On mine it is
`~/.pandoc`.

It is good practice to create a separate `filters`, `preprocessors`, and
`postprocessors` sub directory in your data directory.

If no configuration file is specified when invoking pandocomatic, pandocomatic
tries to find one named **`pandocomatic.yaml`** in the current working
directory or, if there is no such file, the data directory and then the
default data directory.

### Using a pandocomatic template

#### Using a single pandocomatic template

I have saved the above `pandocomatic.yaml`
file in my default data directory. That directory also contains my
postprocessors. Using the *research-to-html* template is easy. Just put the
following metadata block in an input file:

~~~{.yaml}
pandocomatic_:
  use-template: research-to-html
~~~

To generate a HTML file from the input file, run pandocomatic:

~~~{.bash}
pandocomatic --input paper.md --output draft_manuscript.html
~~~

If you write your output to the same file each time you convert
the input file, you can **extend** the template in the input file as follows:

~~~{.yaml}
pandocomatic_:
  use-template: research-to-html
  pandoc:
    output: draft_manuscript.html
~~~

Running pandocomatic becomes even simpler:

~~~{.bash}
pandocomatic paper.md
~~~

That is it!

You can extend the preprocessors used, the postprocessors used, and all pandoc
options. Changing certain options does not make always sense. In this example,
changing the `to` option to `docx` will get you in trouble. Pandoc will run
fine, but when the postprocessors are run on the outputted docx file, things
will get awry. 

No problem, though, for you can add a second template to your configuration
file that generates docx files. For example:

~~~{.yaml}
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
~~~

Just change the used template in your input file to `research-to-docx` and
run pandocomatic to generate a Microsoft Word file I can share with my
colleagues. If the reference docx from the template is not sufficient,
journals like to use slightly different styles after all, you can extend the
template in your input file. No problem.

Using pandocomatic has simplified my workflow for writing papers with pandoc
significantly. Over the years, I have collected a set of templates,
preprocessors, postprocessors, and filters I use over and over.

Note that the pandocomatic YAML property is named `pandocomatic_`. Pandoc has
the [convention](http://pandoc.org/MANUAL.html#metadata-blocks) that YAML
property names ending with an underscore will be ignored by pandoc and can be
used by programs like pandocomatic. Pandocomatic adheres to this convention.
However, for backwards compatibility the property name `pandocomatic` still
works, it just will not be ignored by pandoc.

### Using multiple pandocomatic templates

From pandocomatic version 0.1.13 onwards, pandocomatic supports using more
than one template. For each template used, a conversion is performed. For
example, assuming you have specified templates "web" and "print", which
convert an input markdown file to a HTML or PDF file respectively, passing the
following markdown file to pandocomatic will generate two output files: a HTML
and a PDF file!

~~~{.pandoc}
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
~~~

The rules for multiple templates are the same as for using a single template.

A common use case for using multiple templates is when generating a web site.
Alongside the generated HTML you can also generate a print-ready PDF and link
to it in the HTML file to boot.
