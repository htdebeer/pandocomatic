## Converting a single document

Pandocomatic allows you to put [pandoc command-line
options](http://pandoc.org/MANUAL.html) in the document to be converted
itself. Instead of a complex pandoc command-line invocation, pandocomatic
allows you to convert your markdown document `hello_world.md` with just:

``` {.bash}
pandocomatic hello_world.md
```

Pandocomatic starts by extracting the YAML metadata blocks in
`hello_world.md`, looking for a `pandocomatic_` property. If such a property
exists, it is treated as an **internal pandocomatic template** and the file is
converted according to that **pandocomatic template**. For more information
about *pandocomatic template*s, see the [chapter about
templates](#pandocomatic-templates) later in this manual.

For example, if `hello_world.md` contains the following pandoc markdown text:

```{.pandoc}
::paru::insert ../example/manual/hello_world.md
```

pandocomatic is instructed by the `pandoc` property to convert the document to
the HTML file `hello_world.html`. If you would like to instruct pandocomatic
to convert `hello_world.md` to `goodday_world.html` instead, use command-line
option `--output goodday_world.html`. For more information about
pandocomatic's command-line options, see the [chapter about command-line
options](#pandocomatic_cli).

You can tell pandocomatic to apply any pandoc command-line option in a
template's `pandoc` property. For example, to use a custom pandoc template and
add a custom CSS file to the generated HTML, extend the `pandoc` property
above as follows:

```{.yaml}
pandoc:
    to: html
    css:
    -   style.css
    template: hello-template.html
```

Besides the `pandoc` property to configure the pandoc conversion,
*pandocomatic templates* can also contain a list of **preprocessors** and a
list of **postprocessors**. Preprocessors are run before the document is
converted with pandoc and postprocessors are run afterwards (see the Figure
below): 

![How pandocomatic works: a simple
conversion](documentation/images/simple_conversion.svg)

For example, you can use the following script to clean up the HTML generated
by pandoc:

```{.bash}
::paru::insert ../example/manual/tidy.sh
```

This script `tidy.sh` is a simple wrapper script around the
[html-tidy](https://www.html-tidy.org/) program. To tell pandocomatic to use
it as a postprocessor, you have to change the `pandocomatic_` property to:

```{.yaml}
pandocomatic_:
    pandoc:
        to: html
        css:
        -   style.css
        template: hello-template.html
    postprocessors:
    - ./tidy.sh
```

The "`./`" in the path `./tidy.sh` tells pandocomatic to look for the
`tidy.sh` script in the same directory as the file to convert. You can also
specify an absolute path (starting with a slash "`/`") or a path relative to
the **pandocomatic data directory** like we do in the path in the `template`
property in the example above. See the [Section about specifying paths in
pandocomatic](#specifying-paths) for more information. If you use a path
relative to the *pandocomatic data directory*, you have to use the
`--data-dir` option to tell pandocomatic where to find its data directory.  If
you do not, pandocomatic will default to pandoc's data directory.

To convert the example with a data directory, use:

```{.bash}
pandocomatic --data-dir my_data_dir hello_world.md
```

Like pandoc, pandocomatic does support multiple input files. These input files
are concatenated by pandocomatic and then treated as a single input file. For
example, instead of writing a book in one big markdown file, you could
separate the chapters into separate markdown files. To generate the final
book, invoke pandocomatic like:

```{.bash}
pandocomatic -i frontmatter.md -i c01.md -i c02.md -i c03.md -i c04.md -o book.html
```

Note. If multiple files do have a `pandocomatic_` property in their metadata
blocks, only the first `pandocomatic_` property is used; all other occurrences
are discarded. If this happens, pandocomatic will show a warning.
