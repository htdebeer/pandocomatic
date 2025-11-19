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

### Something goes wrong! How can I figure out what pandocomatic is doing?

Enable logging to see what steps pandocomatic takes while converting your
documents. Use command-line options `--log` and `--log-level DEBUG` to 
tell pandocomatic to log everything. By default `--log` logs to file
`pandocomatic.log`, but you can supply an alternative log file location.

For example:

```{.bash}
pandocomatic --log /tmp/my-log.txt --log-level DEBUG examples/hello_world.md
```

will generate log:

```
# Logfile created on 2025-11-19 13:06:48 +0100 by logger.rb/v1.7.0
2025-11-19 13:06:48 INFO : ------------ START ---------------
2025-11-19 13:06:48 INFO : Running /home/huub/.rbenv/versions/3.5-dev/bin/pandocomatic --log /tmp/my-log.txt --log-level DEBUG example/hello_world.md
2025-11-19 13:06:48 DEBUG: Validating command-line arguments:
2025-11-19 13:06:48 DEBUG: ✓  Option '--input' not used:  treat all arguments after last option as input files or directories.
2025-11-19 13:06:48 DEBUG: ✓  Convert single input file or directory.
2025-11-19 13:06:48 DEBUG: ✓  Input files and directories exist.
2025-11-19 13:06:48 DEBUG: Start conversion:
2025-11-19 13:06:48 INFO : (2) + converting /home/huub/Projects/htdebeer@github.com/pandocomatic/example/hello_world.md 1 time:
2025-11-19 13:06:48 INFO : (1)   - convert hello_world.md -> hello_world.html
2025-11-19 13:06:48 DEBUG:   #  Using internal template.
2025-11-19 13:06:48 DEBUG:   #  Selected template mixed with internal template and pandocomatic metadata gives final template:
                                  extends: []
                                  glob: []
                                  setup: []
                                  preprocessors: []
                                  metadata: {}
                                  pandoc:
                                    from: markdown
                                    to: html5
                                  postprocessors: []
                                  cleanup: []
2025-11-19 13:06:48 DEBUG:   →  Reading source file: '/home/huub/Projects/htdebeer@github.com/pandocomatic/example/hello_world.md'
2025-11-19 13:06:48 DEBUG:      | FileInfoPreprocessor. Adding file information to metadata:
                                     pandocomatic-fileinfo:
                                       from: markdown
                                       to: html5
                                       path: '/home/huub/Projects/htdebeer@github.com/pandocomatic/example/hello_world.md'
                                       src_path: '/home/huub/Projects/htdebeer@github.com/pandocomatic/example/hello_world.md'
                                       created: 2025-04-18
                                       modified: 2024-05-04
2025-11-19 13:06:48 DEBUG:      #  Changing directory to '/home/huub/Projects/htdebeer@github.com/pandocomatic/example'
2025-11-19 13:06:48 DEBUG:      #  Running pandoc
2025-11-19 13:06:48 DEBUG:      |  pandoc       --from=markdown \
                                                --to=html5
2025-11-19 13:06:48 DEBUG:   ←  Writing output to './hello_world.html'.
2025-11-19 13:06:48 INFO : ------------  END  ---------------
```
