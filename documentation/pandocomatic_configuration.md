## Pandocomatic configuration {#pandocomatic-configuration}

Pandocomatic can be configured by means of a *pandocomatic configuration
file*, which is a YAML file. For example, the following YAML code is a valid
*pandocomatic configuration file*:

```{.yaml}
::paru::insert ../example/manual/example_configuration_file.yaml
```

By default, pandocomatic looks for the
configuration file in the *pandocomatic data directory*; by convention this
file is named `pandocomatic.yaml`.

You can tell pandocomatic to use a different configuration file via the
command-line option `--config`. For example, if you want to use a configuration file
`my-config.yaml`, invoke pandocomatic as follows:

```{.bash}
pandocomatic --config my-config.yaml some-file-to-convert.md
```

A *pandocomatic configuration file* contains two sections:

1. global `settings`
2. external `templates`

These two sections are discussed after presenting an example of a
configuration file. For more in-depth information about
pandocomatic templates, please see the [Chapter on pandocomatic
templates](#pandocomatic-templates). 


### Settings

You can configure four optional global settings:

1. `data-dir`
2. `skip`
3. `recursive`
4. `follow-links`

The latter three are used only when running pandocomatic to convert a
directory tree. These are discussed in the next sub section.

The first setting, `data-dir`, tells pandocomatic where its
*data directory* is. You can also specify the *pandocomatic data directory*
via the command-line option `--data-dir`. For example, if you want to use
`~/my-data-dir` as the *pandocomatic data directory*, invoke pandocomatic as
follows:

```{.bash}
pandocomatic --data-dir ~/my-data-dir some-file-to-convert.md
```

If no *pandocomatic data directory* is specified whatsoever, pandocomatic
defaults to pandoc's data directory.

#### Configuring converting a directory tree

### Templates
