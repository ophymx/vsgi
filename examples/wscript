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

def build(bld):
    project.load_build(bld)

def test(ctx):
    project.load_test(ctx)

# vim: set ft=python sw=4 sts=4 et:
