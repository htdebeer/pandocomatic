---
title: Pandocomatic
subtitle: Automating the use of pandoc
author: Huub de Beer
date: September 21st, 2017
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

::paru::insert install.md

::paru::insert why_pandocomatic.md

# Using pandocomatic: Quick start and overview

::paru::insert convert_a_document.md

::paru::insert convert_a_series_of_documents.md

::paru::insert static_site_generator.md

------------------------------------------

# Reference: All about pandocomatic


::paru::insert pandocomatic_cli.md

::paru::insert pandocomatic_templates.md

::paru::insert faq.md

------------------------------------------

# Appendix

::paru::insert glossary.md
