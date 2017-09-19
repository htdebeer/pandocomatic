---
title: About using templates
pandocomatic_:
    use-template: 
    -   my-webpage
    -   my-pdf
    pandoc:
        bibliography: ./a_different_bibliography.bib
    postprocessors:
    -   postprocessors/check_links.sh
...

# Introduction

To use a template, ...
