## Converting a single document

Pandocomatic allows you to put [pandoc command line
options](http://pandoc.org/MANUAL.html) in the document to be converted
itself. Instead of a complex pandoc command line invocation, pandocomatic
allows you to convert your markdown document with just:

``` {.bash}
pandocomatic hello_world.md
```

Pandocomatic starts by mining the [YAML](http://yaml.org/) metadata in
`hello_world.md` for a `pandocomatic_` property. If such a property exists, it
is treated as an **internal pandocomatic template** and the file is converted
according to that **pandocomatic template**. For more information about
*pandocomatic template*s, see the [chapter about
templates](#pandocomatic-templates) in this manual.

For example, if `hello_world.md` contains the following pandoc markdown text:

```{.pandoc}
::paru::insert ../example/manual/hello_world.md
```

pandocomatic is instructed by the `pandoc` section to convert the document to
the [HTML](https://developer.mozilla.org/en-US/docs/Web/HTML) file
`hello_world.html`. With the command-line option `--output
goodday_world.html`, you can instruct pandocomatic to convert
`hello_world.md` to `goodday_world.html` instead. For more information about
pandocomatic's command-line options, see the [chapter about command-line
options](#pandocomatic_cli) in this manual.

You can instruct pandocomatic to apply any pandoc command-line option in the
`pandoc` section. For example, to use a custom pandoc template and add a
[CSS](https://developer.mozilla.org/en-US/docs/Web/CSS) file to the generated
HTML, extend the `pandoc` section as follows:

```{.yaml}
pandoc:
    to: html
    css:
    -   style.css
    template: hello-template.html
```

Besides the `pandoc` section to configure the pandoc conversion,
*pandocomatic templates* can also contain a list of **preprocessors** and
**postprocessors**. Preprocessors are run before the document is converted
with pandoc and postprocessors are run afterwards: 

![How pandocomatic works: a simple
conversion](documentation/images/simple_conversion.svg)

For example, you can use the following script to clean up the HTML generated
by pandoc:

```{.bash}
::paru::insert ../example/manual/tidy.sh
```

This script `tidy.sh` is a simple wrapper script around the
[html-tidy](http://www.html-tidy.org/) program. To instruct pandocomatic to
use it as a postprocessor, you have to change the `pandocomatic_` property to:

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

The path `./tidy.sh` tells pandocomatic to look for the `tidy.sh` script in
the same directory as the file to convert. You can also specify an absolute
path (starting with a slash `/`) or a path relative to the **pandocomatic data
directory** such as for the pandoc `template`. See the [Section about
specifying paths in pandocomatic](#specifiying-paths) for more information. If
you use a path relative to the *pandocomatic data directory*, you have to use
the `--data-dir` option to tell pandocomatic where to find its data directory.

Thus, to convert the above example, use the following pandocomatic invocation:

```{.bash}
pandocomatic --data-dir my_data_dir hello_world.md
```
