---
title: Test links to external CSS files
pandocomatic_:
    pandoc:
        to: html
        standalone: true
        css: 
            -   "without_root_path.css"
            -   "/absolute/path.css"
            -   "../assets/main.css"                     # relative path
            -   "$ROOT$/assets/root_relative_path.css"
...

This is a simple test with four different CSS options.
