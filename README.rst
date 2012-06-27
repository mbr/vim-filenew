===========
vim-filenew
===========

`vim-filenew` is a small vim script that enables templates for filetypes in
vim. Its one special feature is that it allows you to have any number of
templates and will show a window allowing you to select one.

Installation
------------

Copy the ``filenew.vim`` into your ``.vim/plugin`` directory. Or use `VAM
<https://github.com/MarcWeber/vim-addon-manager>`_ (for example, inside your
``.vimrc``::

  call vam#ActivateAddons(['github:mbr/vim-filenew'], {'auto_install' : 1})

Usage
-----

`vim-filenew` will look into all your ``runtimepath`` directories and look for
a subdirectory named ``filenew``. Any file in these directories is considered a
template. Templates must be named ``somename.filetype``, where ``filetype`` is
the name used inside vim.

For example, if you have two HTML-templates, one for HTML4 and one for HTML5,
you could name these ``filenew/html4.html`` and ``filenew/html5.html``.

The first line is considered special if it contains the string
``###vim-file-new``. Anything between this string and ``###`` will be used as
the file description and the line removed.

An example for a HTML5 template::

  <!-- ###vim-file-new A blank, minimal HTML5 file. ### -->
  <DOCTYPE html>
  <html>
    ...
  </html>
