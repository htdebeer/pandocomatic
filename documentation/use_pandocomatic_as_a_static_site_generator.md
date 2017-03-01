After explaining how pandocomatic can be used to automate setting up and
running pandoc for a series of related papers in the [previous
chapter](#automating-setting-up-and-running-pandoc-for-a-series-of-related-papers),
this chapter builds on that while elaborating how to use pandocomatic as a
static site generator. Once pandocomatic could automate the use of pandoc to
convert a file, it was a small step to allow pandocomatic convert multiple
files in a directory at once, recursively. The typical use case for this
feature is to generate a static web site from a directory tree with sub
directories and markdown files.

I learned to create web sites in the late 1990s. I learned how to write HTML
in a simple text editor and to freshen it up a bit with CSS. When I got my own
web server and domain on the internet, I wrote it by hand as well. By that
time I had learned all about content management systems and dynamic web sites,
but I liked the simplicity of expressing myself in HTML. It was a bit more
verbose than LaTeX for sure, but for a couple of web pages that was fine.
Once I started generating more content, however, writing HTML became a hassle.
Not in the least because updating the layout of the site would mean updating
all HTML files. As a result, I stopped updating my web site but for the most
necessary fixes and additions.

In the meantime I had discovered pandoc, wrote a lot of papers and documents
in markdown, and started working on pandocomatic to automate using pandoc to
convert these documents. At that point it seemed only a natural progression to
convert these documents into a web site as well. All I needed, really, was an
HTML template for the web site's layout, and then instruct pandoc to use that
template while generating a standalone HTML file. And then tell pandocomatic
to do that for all files in the source directory, recursively. 

## Configuring pandocomatic to convert a directory tree

The thing about generating a static site is that most input files are
converted using the same pandoc setup. Although a feature that allows complete
customization is great to have, and I have certainly used it in a couple of
times on my web site, pandocomatic allows you to configure a default template,
and to change that configuration for each sub directory. But let see this in
action.

My web site has the following directory structure, with left the source input
directory tree and right the output directory tree:

      /                             /
      + assets                      + assets
        + css                         + css
        + js                          + js
      + ALGOL                       + ALGOL
        - index.md                    - index.html
        - notation.md                 - notation.html
        - creation.md                 - creation.html  
        ...                           ...
      + DR                          + DR
        ...                           ...
      + Education                   + Education
        ...                           ...
      + History                     + History
        + ComputerPioneers            + ComputerPioneers
          ...                           ...
        -> ALGOL                      -> ALGOL
      + Software                    + Software
        + markdown                    + markdown
          + paru                        + paru
            - index.md                    - index.html
          + pandocomatic                + pandocomatic
            - index.md                    - index.html
        ...                           ...
      - about.md                    - about.html
      - publications.md             - publications.html
      - index.md                    - index.html


To generate my [website](https://heerdebeer.org), I use the following command:

~~~{.bash}
pandocomatic -c website-config.yaml -d data-dir -i src-tree -o www-tree
~~~

The configuration file `website-config.yaml` contains the following
configuration:

~~~{.yaml}
::paru::insert website-config.yaml
~~~

Compared to the pandocomatic configuration files in the previous chapter, a
new property is added: **settings**. There are three settings you can
configure:

1.  **recursive**, which tells pandocomatic to also convert the sub
    directories in the current directory or not. The default value is `true`.
2.  **follow-links**, which tells pandocomatic to treat a symbolic link as its
    target, i.e., to follow a link. The default value is `false`, in which
    case pandocomatic tries to recreate a symbolic link in the output. In this
    example, the `ALGOL` link in the sub directory `History/` is recreated in
    the destintion tree.
3.  **skip**, a list of glob patterns of files and directories not to process
    with pandocomatic. By default *hidden files*, those starting with a period
    (`.`), and the *default pandocomatic configuration file* in a directory,
    `pandocomatic.yaml`, are skipped.

If you are happy with the [default
configuration](https://github.com/htdebeer/pandocomatic/blob/master/lib/pandocomatic/default_configuration.yaml),
there is no need to add these properties to your configuration files. If you
want to adapt the current configuration in a sub directory, you create a
`pandocomatic.yaml` file in that sub directory with different settings or an
other template. These new settings and templates are merged with the current
configuration.

*Note.* Currently it is not possible to "unskip" a glob pattern in a sub
directory. If you want to include an hidden file, for example, you're out of
luck. I do intend to add this in a future release.

Pandocomatic converts the input source tree to the output tree as follows:

- for each directory, read `pandocomatic.yaml` if any and merge the
  configuration in that file with the current configuration.
- according to this new configuration, for each item in this directory:
  - ignore the item if it is matched by one of the glob patterns in the `skip`
    property, or
  - recreate all symbolic links that occur in the source tree in the
    destination tree if `follow-links` is false. Otherwise treat the links as
    a file or directory,  or
  - if the item is a director:
    - convert it following these steps if the setting `recursive` is true.
  - if the item is a file:
    - convert all files that are matched by one of the glob patterns of any of
      the templates, or
    - copy the file to the destination directory.

## Using pandocomatic templates

Besides the *settings* property, there is a **templates** property in the
configuration file. This property is configured as explained in the [previous
chapter](#specifying-a-pandocomatic-template). The only difference is the
**glob** property. The *glob* property tells pandocomatic to use this
pandocomatic template to convert all files that match one of the patterns. The
first template with a pattern that is a match for a source file will be used
to convert that file.

Using this configuration, all markdown files recognized by their `.md` or
`.markdown` extension are converted to HTML using the pandoc custom template
`templates/page.html`, with a table of contents, references are formatted
according to APA, and to render mathematics the *mathjax* library is used.
This is the default pandoc configuration I use for most of my files. The
`tidy.sh` postprocessor is used to clean up the output HTML and the
[`site_menu.rb`](https://github.com/htdebeer/pandocomatic/blob/master/documentation/data-dir/preprocessors/site_menu.rb)
preprocessor generates the site's menu. It adds the ancestral directories as
menu items into the source file's metadata, which are rendered by the pandoc
HTML template to render the menu on top of the page.

Sometimes the default configuration is not suited to convert a file or a
directory of files. For example, the file in the directories that contain my
[historical papers](https://heerdebeer.org/History/) should not use the APA
CSL file to render references, but a style that is common for historical
publications like the *Chicago* style. It is easy to extend a template. Just
create a `pandocomatic.yaml` file in that directory and reconfigure a
template:

~~~{.yaml}
::paru::insert website-history-config.yaml
~~~

This works just like [extending templates in a source
file](https://heerdebeer.org/Software/markdown/pandocomatic/#using-a-pandocomatic-template).
If you want to change the template for one specific source file, you can do so
as well.


As you can see, using pandocomatic as a static site generator is
straightforward. Once you have created the initial setup, updating the site is
as easy as rerunning pandocomatic. In that case, the `--modified-only` option
is a great time saver as it only regenerates those files that have been
changed since the last time you generated your web site.

