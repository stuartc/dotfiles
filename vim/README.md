VIM
===

101
---

Toggle case "HellO" to "hELLo" with `g~` then a movement.  
Uppercase "HellO" to "HELLO" with `gU` then a movement.  
Lowercase "HellO" to "hello" with `gu` then a movement.  
Alternatively, you can visually select text then press ~ to toggle case, or U to convert to uppercase, or u to convert to lowercase.

Commenting
----------

  Comment selection or current line (matches indentation)  

    <leader>c

  Comment selection (left aligned style)  

    <leader>cl

Switching Buffers
-----------------

Using [github.com/jeetsukumaran/vim-buffergator](github.com/jeetsukumaran/vim-buffergator)

  Open and closing the buffer catalog

    <Leader>b
    <Leader>B

  Opening and closing the tab page catalog

    <Leader>to
    <Leader>tc

  In addition, in normal mode from any buffer, you can flip through the MRU
  (most-recently-used) buffer list without opening the buffer catalog by using
  the "[b" (or <M-b>) and "]b" (or <M-S-b>) keys.

  http://stackoverflow.com/questions/11979313/command-key-in-macvim

Surrounding Text
----------------

[vim-surround](https://github.com/tpope/vim-surround)

**With the cursor on a word**

  Remove surrounding characters

    ds<character>

    E.g.

    ds" # Removes ""
    ds( # Removes ()

  Add characters around the current word

    ysiw<character>

    E.g.

    ysiw" # Surrounds word with "

Git
---

[vim-gitgutter](https://github.com/airblade/vim-gitgutter)

**Staging Hunks**

  Next and previous hunk

    ]c
    [c
