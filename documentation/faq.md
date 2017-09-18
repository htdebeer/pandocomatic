## Frequently asked questions (FAQ) {#faq}

### How do I use pandoc2 with pandocomatic?

Pandocomatic uses [paru](https://heerdebeer.org/Software/markdown/paru/) to
run pandoc. Paru itself uses the `pandoc` executable in your `PATH`. If that
already is pandoc2, you do not need to do anything.

If you have pandoc1 installed by default, however, and you want to run a
[nightly version of pandoc2](https://github.com/pandoc-extras/pandoc-nightly),
you have to set the `PARU_PANDOC_PATH` to point to the pandoc2 executable. For
example:

```{.bash}
export PARU_PANDOC_PATH=~/Downloads/pandoc-amd64-7c20fab3/pandoc
pandocomatic some-file-to-convert.md
```

### Pandocomatic has too much output! How do I make pandocomatic more quiet?

You can run pandoc in quiet mode by using the `--quiet` or `-q` command-line
option. For example:

```{.bash}
pandocomatic --quiet some-file-to-export.md
```
