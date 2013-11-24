#!/usr/bin/env python
# encoding: utf-8

from valaproj.wscript import Project

top = '.'
out = 'build'
project = Project(out)

APPNAME = project.name()
VERSION = project.version()

def options(opt):
    project.load_options(opt)

def configure(conf):
    project.load_configure(conf)

    conf.check(
        fragment = '#include <fastcgi.h>\nint main(){return 0;}\n',
        lib = 'fcgi',
        uselib_store = 'fcgi',
        mandatory = 1,
        msg = 'checking for libfcgi'
    )

def build(bld):
    project.load_build(bld)

def test(ctx):
    project.load_test(ctx)
