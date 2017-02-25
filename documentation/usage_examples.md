Convert `hello.md` to `hello.html` according to the configuration in
`pandocomatic.yaml`:

~~~{.bash}
pandocomatic --config pandocomatic.yaml -o hello.html -i hello.md
~~~

Generate a static site using data directory `assets`, but only convert files
that have been updated since the last time pandocomatic has been run:

~~~{.bash}
pandocomatic --data-dir assets/ -o website/ -i source/ -m
~~~

Generate the markdown files for pandocomatic's
[manual](https://heerdebeer.org/Software/markdown/pandocomatic/) and its
[github repository](https://github.com/htdebeer/pandocomatic) README:

~~~{.bash}
git clone https://github.com/htdebeer/pandocomatic.git
cd docoumentation
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
`insert_code~block.rb`, and `remove_pandocomatic_metadata.rb`. The first two
filters allow you to include another markdown file or to include a source code
file (see the README listing below). The last filter removes the pandocomatic
metadata block from the file so the settings in it do not interfere with the
translation of the manual to HTML when it is generated as part of the website.
These filters are located in the
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
