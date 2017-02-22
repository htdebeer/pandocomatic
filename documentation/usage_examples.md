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
