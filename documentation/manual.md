---
title: Pandocomatic
subtitle: Automating the use of pandoc
author: Huub de Beer
date: March 1st, 2017
keywords:
- pandoc
- ruby
- paru
- pandocomatic
- static site generator
pandocomatic_:
  use-template: mddoc
  pandoc:
    filter: 
    - 'filters/number_chapters_and_sections_and_figures.rb'
...


# Introduction

::paru::insert introduction.md

## Why pandocomatic?

::paru::insert why_pandocomatic.md

But more about that later. First, the installation of pandocomatic is
described, followed by its license.  After that, in the next chapters, using
pandocomatic and configuring pandocomatic are described in detail. The last
two chapters of this manual describe two typical use cases of pandocomatic:

1.  [automating setting up and running pandoc for a series of related papers](#automating-setting-up-and-running-pandoc-for-a-series-of-related-papers), and 
2.  [using pandocomatic as a static site
    generator](#using-pandocomatic-as-a-static-site-generator).

## Licence

::paru::insert license.md

## Installation

::paru::insert install.md

# Using pandocomatic

::paru::insert usage.md

## Examples

::paru::insert usage_examples.md


See Chapters
[4](#use-case-i-automating-setting-up-and-running-pandoc-for-a-series-of-related-papers)
and
[5](#use-case-ii-use-pandocomatic-as-a-static-site-generator)
for more extensive examples on how to use pandocomatic.

In the next chapter the configuration of pandocomatic is elaborated.

# Configuring pandocomatic

::paru::insert configuration.md

# Automating setting up and running pandoc for a series of related papers

::paru::insert use_pandocomatic_to_automate_pandoc.md

# Using pandocomatic as a static site generator

::paru::insert use_pandocomatic_as_a_static_site_generator.md


