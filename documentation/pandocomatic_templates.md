## Pandocomatic templates {#pandocomatic-templates}

Pandocomatic automates the use of pandoc by extracting common patterns
of using pandoc into so called *pandocomatic templates*. You can then apply
these templates to your documents. As described in [Part II](#using-pandocomatic), there are
**internal** and **external** *pandocomatic templates*. The difference between
these two types of templates is their scope: *internal pandocomatic templates*
only affect the document they are defined in, whereas *external pandocomatic
templates*, which are defined in a *pandocomatic configuration file*, affect
all documents that use that template.

Although you can create an one-off *internal pandocomatic template* for a
document—sometimes you just have an odd writing project that differs too much
from your regular writings—, most often you use an *external pandocomatic
template* and customize it in the *internal pandocomatic template*.

In this Chapter the definition, extension, customization, and use of templates
are discussed in detail.

### Defining a template

An *external pandocomatic template* is defined in the `templates` property of a
*pandocomatic configuration file*. For example, in the following YAML code,
the template `webpage` is defined:

```{.yaml}
::paru::insert ../example/manual/example_configuration_file.yaml
```

Each template is a sub property in the `templates` property. The property name
is the template name. The property value is the template's definition. A
template definition can contain the following sub properties:

- `extends`
- `glob`
- `setup`
- `preprocessors`
- `metadata`
- `pandoc`
- `postprocessors`
- `cleanup`

Before discussing these properties in detail, the way pandocomatic resolves
paths used in these sections is described first because paths can be used in
most of these properties.

#### Specifying paths {#specifying-paths}

Because templates can be used in any document, specifying paths pointing to
assets to use in the conversion process is not straightforward. Using global
paths works, but has the disadvantage that the templates are no longer easily
shareable with others. Using local paths works if the assets and the document
to convert are located in the same directory, but that does not hold for more
general *external pandocomatic templates*. As a third alternative,
pandocomatic also supports paths that are relative to the *pandocomatic data
directory*.

You can specify these types of paths as follows:

1.  All *local* paths start with `./`. These paths are local to the
    document being converted. When converting a directory tree, the current
    directory is being prepended to the path minus the `./`.

    On the Windows operating system, a *local* path starts with `.\`.  Note
    that backslashes might need escaping, like `.\\`.
2.  *Global* paths start with a `/`. These paths are resolved as is. On the
    Windows operating system, a *global* path starts with a letter followed by
    a colon and a backslash, for example `C:\`.  Note
    that backslashes might need escaping, like `C:\\`.
3.  Paths *relative* to the *pandocomatic data directory* do not start with a
    `./` nor a `/`. These paths are resolved by prepending the path to the
    *pandocomatic data directory*. These come in handy for defining general
    usable *external pandocomatic templates*.

    *Note.* For filters, processors, and start-up or clean-up scripts, the
    path is first checked against the `PATH`. If pandocomatic finds an
    executable matching the path, it will resolve that executable instead.

#### Template properties

##### extends

A template can extend zero or more templates by supplying a list of template
names to extend. The extension builds from left to right.

For more detailed information about extending templates, see the [Section
about extending templates](#extending-pandocomatic-templates) below.

**Examples**

-   Extend from template `webpage`:

    ```{.yaml}
    extends: ['webpage']
    ```

    If only one template is extended, a string value is also allowed. The
    following has the same effect as the example above:


    ```{.yaml}
    extends: webpage
    ```

-   Extend from templates `webpage` and `overview`:
    
    ```{.yaml}
    extends: ['webpage', 'overview']
    ```

    Note. If both templates have overlapping or contradictory configuration,
    the above extension can be different from the one below:
    
    ```{.yaml}
    extends: ['overview', 'webpage']
    ```

##### glob

When a template is used for converting files in a directory tree, you can
specify which files in the directory should be converted by a template. The
`glob` section expects a list of [glob
patterns](http://ruby-doc.org/core-2.4.1/Dir.html#method-c-glob). All files
that match any of these glob patterns are converted using this template.

When there are more templates that have matching glob patterns, the first one
is used.

If there is also a `skip` configured (see the [Section on global
settings](#global-settings), the `skip` setting has precedence over the `glob`
setting. Thus, if `skip` is `['*.md']` and `glob` is `['*.md']`, the template
will not be applied.

**Examples**

-   Apply this template to all files with extension `.md` (i.e. all markdown
    files):

    ```{.yaml}
    glob: ['*.md']
    ```

-   Apply this template to all HTML files and all files starting with
    `overview_`:

    ```{.yaml}
    glob: ['overview_*', '*.html']
    ```

##### setup

For more involved conversion patterns, some setup of the environment might be
needed. Think of setting Bash environment variables, creating temporary
directories, or even installing third party tools needed in the conversion.
Startup scripts can be any executable script or program.

Setup scripts are run before the conversion process starts. 


**Examples**

-   ```{.yaml}
    setup:
    - scripts/create_working_directory.sh
    ```

##### preprocessors

After setup, pandocomatic executes all preprocessors in order of specification
in the `preprocessor` property, which is a list. A preprocessor is any
executable script or program that takes as input the document to convert and outputs that
document after "preparing" it somehow.  You can use a preprocessor to add
metadata, include other files, replace strings, and so on.

**Examples**

-   Add the today's date to the metadata:

    ```{.yaml}
    preprocessors: ['preprocessors/today.sh']
    ```

    Note. You can also use a [filter to mix in the
    date](https://github.com/htdebeer/paru/blob/master/examples/filters/add_today.rb).

##### metadata

Metadata is used in pandoc's templates as well as a means of communicating
with a filter. Some metadata is common to many documents, such as language,
author, keywords, and so on. In the `metadata` property of a template you can
specify this global metadata. The `metadata` property is a key-value list.

**Examples**

-   For example, all document I write have me as the author:

    ```{.yaml}
    metadata:
        author: Huub de Beer
    ```

##### pandoc

To actually control the pandoc conversion process itself, you can specify any
pandoc command-line option in the `pandoc` property, which is a key-value list.

**Examples**

-   Convert markdown to a standalone HTML document with a table of contents:

    ```{.yaml}
    pandoc:
        from: markdown
        to: html
        toc: true
        standalone: true
    ```

-   Convert markdown to ODT with citations:

    ```{.yaml}
    pandoc:
        from: markdown
        to: odt
        bibliography: 'assets/bibligraphy.bib'
        toc: 'assets/APA.csl'
    ```    

For convenience, the virtual output format `pdf` is added by pandocomatic. It
allows you to specify PDF output without needing to use the `output` option.
This allows for general pandoc configurations for generating PDF files. You
specify the PDF output format by `to: pdf`. Pandocomatic will determine the
actual output format based on the value of `pdf-engine`. If that option is not
set, pandocomatic defaults to `latex`.

To give the use more control over what filename extension will be used, the
virtual pandoc option `use-extension` has been added. If set, and the `output`
option is not being used, the value of the `use-extension` option is used as
the extension of the output file. For example, to generate a PDF presentation
using the beamer output format, you can specify the following pandoc options:

```{.yaml}
pandoc:
    from: markdown
    to: beamer
    use-extension: pdf
```

Finally, the virtual pandoc option `rename` has been added to allow you to
rename the output file via a script. This script will receive the destination
path on `STDIN` and is supposed to write the renamed output path to `STDOUT`.
It allows you to perform quite complex behavior with regards to the output
directory and name of output files.

I use this virtual pandoc option when I am generating my static
sites with both HTML and PDF output and my input file is named `index.md`. For
the HTML format I want `index.html` as the output file name, but for the PDF
output I do not want `index.pdf` as output filename. Instead, I prefer to use
the name of the input directory with extenstion `.pdf`. To that end I setup
pandocomatic as follows:

```{.yaml}
pandoc:
    from: markdown
    to: pdf
    rename: use-dirname.rb
```

and `use-dirname.rb`:

```{.ruby}
#!/usr/bin/env ruby

current_dst = $stdin.read
current_dst_dir = File.dirname current_dst
current_dst_filename = File.basename current_dst
current_dst_extname = File.extname current_dst

dirname = File.split(current_dst_dir).last

if current_dst_filename.start_with? "index" and not dirname.nil?
    puts File.join(current_dst_dir, "#{dirname}.#{current_dst_extname}")
else 
    puts current_dst
end

```

##### postprocessors

Similar to the `preprocessors` property, the `postprocessors` property is a
list of scripts or programs to run after the pandoc conversion has finished.
Each postprocessor takes as input the converted document and outputs that
document with the changes made by the postprocessor. Postprocessors come in
handy for cleaning up output, checking for dead links, do string replacing,
and so on.

**Examples**

-   Clean up the HTML generated by pandoc through the `tidy` program:

    ```{.yaml}
    postprocessors: ['postprocessors/tidy.sh']
    ```

##### cleanup

The counterpart of the `setup` property. The `cleanup` property is a list of
scripts or programs to run after the conversion of the document. It can be
used to clean up temporary files, resetting the environment, uploading the
resulting document, and so on.

**Examples**

-   Deploy a generated HTML file to your website:

    ```{.yaml}
    cleanup: ['scripts/upload_and_remove.sh']
    ```

### Extending pandocomatic templates {#extending-pandocomatic-templates}

Using the `extends` property of a template, you can mix and extend multiple
templates. For example, building on the `webpage` template, I can create a
`my-webpage` template like so:

```{.yaml}
::paru::insert ../example/manual/extended_example_configuration_file.yaml
```

This `my-webpage` templates extends the original by:

- it always has my name as author
- it sets "today" as the date so the date gets updated automatically whenever
  I convert a document with this template
- and uses my bibliography for generating references.

#### Extension rules

Although extension of templates is relatively straightforward, there are some
nuances to the extension rules to keep in mind. Basically there are three
cases:

1.  If the parent template has a property, but the child does not, the
    resulting template has the parent's property. Examples:

    ```
    parent = 4 ∧ child = ⊘ ⇒ 4
    parent = [4, 5] ∧ child = ⊘ ⇒ [4, 5]
    ```

2.  If the parent template does not have a property, but the child does, the
    resulting template has the child's property.

    ```
    parent = ⊘ ∧ child = 4 ⇒ 4
    parent = ⊘ ∧ child = {a: 1} ⇒ {a: 1}
    ```

3.  If both parent and child templates do have a property, the resulting
    template will have that property and its value is determined as follows:

    1.  If the child's value is of a simple type, such as a string, number, or
        Boolean, the resulting property will have the value of the child.
        Examples:

        ```
        parent = 4 ∧ child = true ⇒ true
        parent = [4, 5] ∧ child = "yes" ⇒ "yes"
        parent = {key: true} ∧ child = 12 ⇒ 12
        ```

    2.  If parent and child values both are key-value lists, the resulting value will be
        the child's key-value list merged with the parent's key-value list. Examples:
        
        ```
        parent = {a: 1, b: 2} ∧ child = {a: 2, c: 3} ⇒ {a: 2, b: 2, c: 3}
        parent = {a: 1, b: 2} ∧ child = {a: , c: 3} ⇒ {b: 2, c: 3}
        ```

    3.  If the parent value is a list, two different extension mechanisms can
        take effect depending on the type of the child's value:
        
        1.  If the child is a list as well, the resulting value will be the
            child's list merged with the parent's list. Duplicate values will
            be removed. Lists in pandocomatic templates are treated as sets.
            Examples:

            ```
            parent = [1] ∧ child = [2] ⇒ [1, 2]
            parent = [1] ∧ child = [1, 2] ⇒ [1, 2]
            ```

        2.  If the child is a key-value list, it is assumed to have keys `remove`
            and `add`. The resulting value will be the parent's
            value with the items from the `remove` list removed and
            items from the `add` list added. Examples:

            ```
            parent = [1] ∧ child = {'remove': [1], 'add': [3]} ⇒ [3]
            parent = [1, 2] ∧ child = {'remove': [1]} ⇒ [2]
            ```

To remove a property in a child template, that child's value should be
`nil`. You can create a `nil` value in YAML by having a key without a value.

### Customizing an external template in an internal template

To use an *external pandocomatic template* you have to use it in a document by
creating an *internal pandocomatic template* which has the `use-template`
property set to the name of the *external pandocomatic template*. After that,
you can customize the template to suit the document it is used in, for example
adding extra pandoc command-line options or adding another preprocessor.

You create an *internal pandocomatic template* by adding a `pandocomatic_`
property to the document's YAML metadata. The `pandocomatic_` property can have
the same properties as an *external pandocomatic template* except for the
`glob` and `extends` properties. (Actually, you can add these two properties as
well, but they are ignored.)

For example, if you use the `my-webpage` template, but you would like to use a
different bibliography and check all links in the converted document, your
document would look like:

```{.pandoc}
::paru::insert ../example/manual/use_my_webpage.md
```

#### Multiple conversions

The `use-template` property can also be a list of *external pandocomatic
template* names. In that case, the document is converted once for each of
these templates. For example, this allows you to generate both a HTML and a
PDF version of a document at the same time:

```{.pandoc}
::paru::insert ../example/manual/use_my_webpage_and_print.md
```

Do note, however, that an *internal pandocomatic template* will apply to all
used *external pandocomatic templates*. It is not possible to customize one
used template differently than another. This means that you have to move the
customization to the used *external pandocomatic templates* or you have
customize the *internal pandocomatic template* such that it is applicable to
all used *external pandocomatic templates* (as in the example above).
