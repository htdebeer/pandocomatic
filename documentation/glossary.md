## Glossary

pandocomatic template

:   A pandocomatic template specified the conversion process executed by
pandocomatic. It can contain the following properties:

- glob
- extends
- setup
- preprocessors
- metadata
- pandoc
- postprocessors
- cleanup

internal pandocomatic template

:   A pandocomatic template specified in a pandoc markdown file itself via the
YAML metadata property `pandocomatic_`.

external pandocomatic template

:   A pandocomatic template specified in a *pandocomatic configuration file*.

preprocessors

:   A preprocessor applied to an input document before running pandoc.

postprocessors

:   A postprocessor applied to an input document after running pandoc.

pandocomatic data directory

:   The directory used by pandocomatic to resolve relative paths. Use this
directory to store preprocessors, pandoc templates, pandoc filters,
postprocessors, setup scripts, and cleanup scripts. It defaults to pandoc's data
directory.

pandocomatic configuration file

:   The configuration file specifying *external pandocomatic templates* as
well as settings for converting a directory tree. Defaults to
`pandocomatic.yaml`.

extending pandocomatic templates

:   *External pandocomatic templates* can extend other *external pandocomatic
templates*. By using multiple smaller *external pandocomatic templates* it is
possible to setup your templates in a modular way. Pandocomatic supports
extending from multiple *external pandocomatic templates*.

static-site generator

:   Pandocomatic can be used as a static-site generator by running
pandocomatic recursivel on a directory. Pandocomatic has some specific
congiguration options to be used as a static-site generator.
