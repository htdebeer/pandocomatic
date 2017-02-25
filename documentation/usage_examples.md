### Convert a single file

Convert `hello.md` to `hello.html` according to the configuration in
`pandocomatic.yaml`:

~~~{.bash}
pandocomatic --config pandocomatic.yaml -o hello.html -i hello.md
~~~

### Convert a directory

Generate a static site using data directory `assets`, but only convert files
that have been updated since the last time pandocomatic has been run:

~~~{.bash}
pandocomatic --data-dir assets/ -o website/ -i source/ -m
~~~

### Generating pandocomatic's manual and README files

Generate the markdown files for pandocomatic's
[manual](https://heerdebeer.org/Software/markdown/pandocomatic/) and its
[github repository](https://github.com/htdebeer/pandocomatic) README:

~~~{.bash}
git clone https://github.com/htdebeer/pandocomatic.git
cd documentation
pandocomatic --data-dir data-dir --config config.yaml -i README.md -o ../README.md
pandocomatic --data-dir data-dir --config config.yaml -i manual.md -o ../index.md
~~~

Be careful to not overwrite the input file with the output file! I would
suggest using different names for both, or different directories. Looking more
closely to the pandocomatic configuration file `config.yaml`, we see it
contains one template, `mddoc`:

~~~{.yaml}
::paru::insert config.yaml
~~~

The `mddoc` template tells pandocomatic to convert a markdown file to a
standalone markdown file using three filters: `insert_document.rb`,
`insert_code_block.rb`, and `remove_pandocomatic_metadata.rb`. The first two
filters allow you to include another markdown file or to include a source code
file (see the README listing below). The last filter removes the pandocomatic
metadata block from the file so the settings in it do not interfere when,
later on, `manual.md` is converted to HTML.  These filters are located in the
[`filters`](https://github.com/htdebeer/pandocomatic/tree/master/documentation/data-dir/filters)
subdirectory in the specified data directory `data-dir`.

However, the `mddoc` template converts from and to pandoc's markdown variant,
which differs slightly from the markdown variant used by
[Github](https://github.com/) for README files. Luckily, pandoc does support
writing Github's markdown variant. There is no need to create and use a
different template for generating the README, though, as you can override all
template's settings inside a pandocomatic block in a markdown file:

~~~{.markdown}
::paru::insert README.md
~~~

Here you see that the README uses the `mddoc` template and it overwrites the
`to` property with `markdown_github`.

Similarly, in the input file
[`manual.md`](https://github.com/htdebeer/pandocomatic/blob/master/documentation/manual.md),
an extra filter is specified, ['number_chapters_and_sections_and_figures.rb'](https://github.com/htdebeer/pandocomatic/blob/master/documentation/data-dir/filters/number_chapters_and_sections_and_figures.rb), to number the chapters and sections in the manual, which is not needed for the README, by using the following pandocomatic metadata in the manual input file:

~~~{.yaml}
pandocomatic:
  use-template: mddoc
  pandoc:
    filter: 
    - 'filters/number_chapters_and_sections_and_figures.rb'
~~~ 

Pandocomatic allows you to generalize common aspects of running pandoc while
still offering the ability to be as specific as needed.
