Vala Server Gateway Interface
=============================

[![Build Status](https://travis-ci.org/ophymx/vsgi.png)]
(https://travis-ci.org/ophymx/vsgi)

The Vala Server Gateway Interface (VSGI) is a library for developing middleware
for Vala and GObject based web applications.

## Requirments
- `valac >= 0.16` __build only__
- `python >= 2.3` __build only__
- `glib >= 2.32`
    - glib-2.0
    - gobject-2.0
    - gio-2.0
    - gmodule-2.0
- `gee-1.0 >= 0.6`
- `libfcgi >= 2.4.0`

## Build
VSGI uses the waf build tool.
To configure, build, and install simple do the following:

    ./waf configure
    ./waf
    ./waf install
