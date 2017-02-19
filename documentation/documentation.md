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
    output: ../index.md
    standalone: true
    filter: 
    - filters/insert_document.rb
    - filters/number_chapters_and_sections_and_figures.rb
    - filters/insert_code_block.rb
    - filters/remove_pandocomatic_metadata.rb
...


# Introduction

## Why pandocomatic?

::paru::insert why_pandocomatic.md

## Licence

::paru::insert license.md

## Installation

::paru::insert install.md

