---
title: Usage of multiple input files
author: HT de Beer
pandocomatic_:
  pandoc:
    to: latex
...
# Usage

To use multiple input files, make sure that:

- Only files can be used, no directories
- Do not mix `--input/-i` options and extra input paramters:

  - Good:

    ```
    pandocomatic -i 1.md -i 2.md
    pandocomatic 1.md 2.md
    pandocomatic --input 1.md -i 2.md
    ```

  - Bad:

    ```
    pandocomatic -i somedir -i 1.md
    ```
