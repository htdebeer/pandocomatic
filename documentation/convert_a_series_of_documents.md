## Converting a series of documents

### Using external templates

Adding an *internal pandocomatic template* to a markdown file helps a lot by
simplifying converting that file with pandoc. Once you start using pandocomatic
more and more, you will discover that most of these
*internal pandocomatic templates* are a lot alike. You can re-use these
*internal pandocomatic templates* by moving the common parts to an **external
pandocomatic template**.

*External pandocomatic template*s are defined in a **pandocomatic
configuration file**. A *pandocomatic configuration file* is a YAML file.
Templates are specified in the `templates` property as named sub properties.
For example, the *internal pandocomatic template* specified in the
`hello_world.md` file (see previous chapter) can be specified as the *external
pandocomatic template* `hello` in the *pandocomatic configuration file*
`my-config.yaml` as follows:

```{.yaml}
::paru::insert ../example/manual/my-config.yaml
```

You use it in a pandoc markdown file by specifying the `use-template` option
in the `pandocomatic_` property. The `hello_world.md` example then becomes:

```{.pandoc}
::paru::insert ../example/manual/external_hello_world.md
```

To convert `external_hello_world.md` you need to tell pandocomatic where to
find the *external pandocomatic template* via the `--config` command-line
option. For example, to convert `external_hello_world.md` to `out.html`, use:

```{.bash}
pandocomatic -d my_data_dir --config my-config.yaml -i external_hello_world.md -o out.html
```

### Customizing external templates with an internal template

Because you can use an *external pandocomatic templates* in many files, these
external templates tend to setup more general options of a conversion process.
You can customize a conversion process in a particular document by extending
the *internal pandocomatic template*. For example, if you want to apply a
different CSS style sheet and adding a table of contents, customize the
`hello` template with the following *internal pandocomatic template*:

```{.yaml}
pandocomatic_:
    use-template: hello
    pandoc:
        toc: true
        css:
            remove:
            - './style.css'
            add:
            - './goodbye-style.css'
```

`hello`'s `pandoc` section if extended with the `--toc` option, the
`style.css` is removed, and `goodbye-style.css` is added. If you want to add
the `goodbye-style.css` rather than have it replace `style.css`, you would
specify:

```{.yaml}
css:
    -   './goodbye-style.css'
```

Lists and properties in *internal pandocomatic templates* are merged with
*external pandocomatic templates*; simple values, such as strings, numbers, or
Booleans, are replaced. Besides the `pandoc` section of a template you
can also customize other template sections.


### Extending templates

In a similar way that an *internal pandocomatic template* extends an *external
pandocomatic template* you can also **extend** an *external pandocomatic
template* directly in the *pandocomaitc configuration file*. For example,
instead of customizing the `hello` template, you could also have extended
`hello` as follows:

```{.yaml}
::paru::insert ../example/manual/my-extended-config.yaml
```

The 'goodbye' template *extends* the `hello` template. A template can *extend*
multiple templates. For example, you could write a template `author` in which
you configure the `author` metadata variable:

```{.yaml}
templates:
    author:
        metadata:
            author: Huub de Beer
    ...
```

This `author` template specifies the `metadata` section of a template. This
metadata will be mixed into each document that uses this template. If you want
the `goodbye` template to also set the author automatically, you can change
its `extends` section to:

```{.yaml}
templates:
    ...
    goodbye:
        extends: ['author', 'hello']
        ...
``` 

Setting up templates by extending other smaller templates makes for a modular
setup. If you share your templates with someone else, she only has to change
the `author` template to her own name in one place to automatically put her
name on all her documents while using your templates.

See the [Section on extending pandocomatic
templates](#extending-pandocomatic-templates) for more information about
this extension mechanism.
