## Pandocomatic templates {#pandocomatic-templates}

Pandocomatic automates the use of pandoc by extracting common usage patterns
of pandoc into so called *pandocomatic templates*, which you can then apply to
your documents. As described in [Part II](#using-pandocomatic), there are
**internal** and **external** *pandocomatic templates*. The difference between
these two types of templates is their scope: *internal pandocomatic templates*
only affect the document they are defined in, whereas *external pandocomatic
templates*, which are defined in a *pandocomatic configuration file*, affect
all documents that use that template.

Although you can create a one-off *internal pandocomatic template* for a
document—sometimes you just have an odd writing project that differs too much
from your regular writings—, most often you use an *external pandocomatic
template* and customize it in the *internal pandocomatic template*.

In this Chapter the definition, extension, customization, and use of templates
are discussed in detail.

### Defining a template

An *external pandocomatic template* is defined in the `templates` section of a
*pandocomatic configuration file*. For example, in the following YAML code,
the template `webpage` is defined:

```{.yaml}
::paru::insert ../example/manual/example_configuration_file.yaml
```

Each template is a YAML property in the `templates` section. The property name
is the template name. The property value is the template's definition. A
template definition can contain the following sections:

- `extends`
- `glob`
- `setup`
- `preprocessors`
- `metadata`
- `pandoc`
- `postprocessors'
- `cleanup`

Before discussing these sections in detail, the way pandocomatic resolves
paths used in these sections is described first.

#### Specifying paths {#specifying-paths}

Because templates can be used in any document, specifying paths to assets to
use in the conversion process is not straightforward. Using global paths only
could work, but has the disadvantage that the templates are no longer
shareable with others. Using local paths works only if the assets and the
document to convert are located in the same directory. As a third alternative,
pandocomatic also supports paths that are relative to the *pandocomatic data
directory*.

You can specify these types of paths as follows:

1. All **local** paths start with a `./`. These paths are local to the
   document being converted. When converting a directory tree, the current
   directory is being prepended to the path minus the `./`.
2. **global** paths start with a `/`. These paths are resolved as is.
3. paths **relative** to the *pandocomatic data directory* do not start with a
   `./` nor a `/`. These paths are resolved by prepending the path to the
   *pandocomatic data directory*.

#### Template sections

##### `extends`

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
    this extension can be different from:
    
    ```{.yaml}
    extends: ['overview', 'webpage']
    ```

##### `glob`

When a template is used for converting files in a directory tree, you can
specify which files in the directory should be converted by a template. The
`glob` section expects a list of [glob
patterns](http://ruby-doc.org/core-2.4.1/Dir.html#method-c-glob). All files
that match any of these glob patterns are converted using this template.

When there are more templates that have matching glob patterns, the first one
is used.

If there is also a `skip` configured (see the [Section on global
settings](#global-settings), the `skip` setting has precedence of the `glob`
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

##### `setup`

**Examples**

-   the example:

    ```{.yaml}
    ```

##### `preprocessors`

**Examples**

-   the example:

    ```{.yaml}
    ```

##### `metadata`

**Examples**

-   the example:

    ```{.yaml}
    ```

##### `pandoc`

**Examples**

-   the example:

    ```{.yaml}
    ```

##### `postprocessors`

**Examples**

-   the example:

    ```{.yaml}
    ```

##### `cleanup`

**Examples**

-   the example:

    ```{.yaml}
    ```

### Extending pandocomatic templates {#extending-pandocomatic-templates}

### Extension rules

#### Simple values

#### Maps

#### Lists (or rather sets)

#### Modularity 

### Customizing a template

#### `use-template`

#### Multiple conversions
