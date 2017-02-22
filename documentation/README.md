---
pandocomatic:
  pandoc:
    from: markdown
    to: markdown_github
    standalone: true
    filter: 
    - filters/insert_document.rb
    - filters/insert_code_block.rb
    - filters/remove_pandocomatic_metadata.rb
...

# Pandocomatic—Automating the use of pandoc


::paru::insert introduction.md

## Why pandocomatic?

::paru::insert why_pandocomatic.md

## Licence

::paru::insert license.md

## Installation

::paru::insert install.md

## More information

For more information on pandocomatic, please see its
[manual](https://heerdebeer.org/Software/markdown/pandocomatic/). In it, the
usage and configuration of pandocomatic are detailed. Furthermore, the manual
contains two chapters describing typical use cases for pandocomatic: i)
automating setting up and running pandoc for a series of related papers and
ii) using pandocomatic as a static site generator.
