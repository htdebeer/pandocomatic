## Converting a directory tree of documents

Once you have created a number of documents that can be converted by
pandocomatic, and you change something significant in one of the *external
pandocomatic templates*, you have to run pandocomatic on all of the documents
again to propagate the changes. That is fine for a document or two, but more
than that and it becomes a chore.

For example, if you change the pandoc template `hello-template.html` in the
*pandocomatic data directory*, or switch to another template, you need to
regenerate all documents you have already converted with the old pandoc
template. If you run pandocomatic on an input  directory rather than one input
file, it will convert all files in that directory, recursively. 

Thus, to convert the example files used in this chapter, you can run

```{.bash}
pandocomatic -d my_data_dir -c my-extended-config.yaml -i manual -o output_dir
```

It will convert all files in the directory `manual` and place the generated
documents in the output directory `output_dir`.

From here it is but a small step to use pandocomatic as a **static-site
generator**. For that purpose some configuration options are available:

-   a settings section in a *pandocomatic configuration file* to control
    -   running pandocomatic recursively or not
    -   follow symbolic links or not
-   a `glob` section in an *external pandocomatic template* telling
    pandocomatic to apply the template to which files in the directory
-   and the convention that a file named `pandocomatic.yaml` in a directory is
    used as the *pandocomatic configuration file* to control the conversion of
    the files in that directory
-   a command-line option `--modified-only` to only convert the files that
    have changes rather than to convert all files in the directory.

With these features, you can (re)generate a website with the pandocomatic
invocation:

```{.bash}
pandocomatic -d data_dir -c intitial_config.yaml -i src -o www --modified-only
```

For more detailed information about pandocomatic, please see the
[Reference](#reference) section of this manual.
