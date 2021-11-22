---
pandocomatic:
  pandoc:
    from: markdown
    to: html
    filter:
      # - somefilterthatscommentedout.rb
    css:
    - style.css
...
*Hello world!*, from **pandocomatic**.
