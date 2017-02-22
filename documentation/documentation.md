---
title: Pandocomatic—Automating the use of pandoc
author: Huub de Beer
keywords:
- pandoc
- ruby
- paru
- pandocomatic
- static site generator
pandocomatic:
  pandoc:
    from: markdown
    to: markdown
    standalone: true
    filter: 
    - filters/insert_document.rb
    - filters/number_chapters_and_sections_and_figures.rb
    - filters/insert_code_block.rb
    - filters/remove_pandocomatic_metadata.rb
...


# Introduction

::paru::insert introduction.md

## Why pandocomatic?

::paru::insert why_pandocomatic.md

But more about that later. First, the installation of pandocomatic is
described, followed by its license.  After that, in the next chapters, using
pandocomatic and configuring pandocomatic are described in detail. The last
two chapters of this manual describe two typical use cases for pandocomatic:
i) automating setting up and running pandoc for a series of related papers and ii)
using pandocomatic as a static site generator.

## Licence

::paru::insert license.md

## Installation

::paru::insert install.md

# Using pandocomatic

::paru::insert usage.md

# Configuring pandocomatic

::paru::insert configuration.md

# Use case I: Automating setting up and running pandoc for a series of related papers

::paru::insert use_pandocomatic_to_automate_pandoc.md

# Use case II: Use pandocomatic as a static site generator

::paru::insert use_pandocomatic_as_a_static_site_generator.md


