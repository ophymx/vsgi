#!/usr/bin/env python
# encoding: utf-8

import ConfigParser
import os
import errno
from waflib import Errors
from subprocess import call

top = '.'
out = 'build'

def options(opt):
    opt.load('compiler_c')
    opt.load('vala')

def configure(conf):
    conf.load('compiler_c')
    conf.load('vala')
    min_glib_version = '2.32.0'
    glib_libraries = [ 'glib', 'gobject', 'gio', 'gmodule' ]
    for lib in glib_libraries:
        lib += '-2.0'
        conf.check_cfg(
            package = lib,
            uselib_store = lib ,
            atleast_version = min_glib_version,
            args = '--cflags --libs')

    conf.check_cfg(
        package = 'gee-1.0',
        uselib_store = 'gee-1.0',
        atleast_version = '0.6.0',
        args = '--cflags --libs')

    conf.check(
        fragment = '#include <fastcgi.h>\nint main(){return 0;}\n',
        lib = 'fcgi',
        uselib_store = 'fcgi',
        mandatory = 1,
        msg = 'checking for libfcgi')

    version_config = ConfigParser.SafeConfigParser({
        'version': '0.0.1',
        'api_version': '1.0'
    })
    version_config.read('version.cfg')

    version = version_config.get('default', 'version')
    conf.env['VERSION']     = version
    conf.env['API_VERSION'] = version_config.get('default', 'api_version')
    conf.env['SO_VERSION']  = '.'.join(version.split('.')[:2])

def get_dirs(dir):
    try:
        return [d for d in os.listdir(dir) if not d.startswith('.')]
    except OSError, e:
        if e.errno == errno.ENOENT:
            return []
        raise

def path_join(*args):
    return os.path.join(*args)

def valid_pkg_config_package(pkg):
    return len(pkg) > 0 and call(['pkg-config', pkg]) == 0

def pkg_config_packages(pkgs):
    pkgs = [p for p in pkgs.split(" ") if valid_pkg_config_package(p)]
    return " ".join(pkgs)


def build(bld):
    default_build_config = {
        'packages': '%(external)s %(internal)s',
        'external': '',
        'internal': '',
        'description': ''
    }

    vapi_dirs = ['.', 'vapi']

    # FIXME: sorting libs here to keep dependency order. Just so happens to be
    #        correct for this project. Need to patch upstream so that vala 'use'
    #        can be evaluated later (after all tasks are defined).
    for lib in sorted(get_dirs('src/lib')):
        lib_dir = path_join('src/lib', lib)
        build_config = ConfigParser.SafeConfigParser(default_build_config)
        build_config.read(path_join(lib_dir, 'build.cfg'))

        gir_name = build_config.get('default', 'gir_name')

        bld(features='c cshlib',
            target = '%s-%s' % (lib, bld.env.API_VERSION),
            pkg_name = lib,
            source = bld.path.ant_glob(path_join(lib_dir, '**/*.vala')),
            gir = '%s-%s' % ( gir_name, bld.env.API_VERSION ),
            vapi_dirs = vapi_dirs,
            vnum = bld.env.SO_VERSION,
            uselib = build_config.get('packages', 'external'),
            packages = build_config.get('packages', 'external'),
            use = build_config.get('packages', 'internal'))

        packages = " ".join([
            pkg_config_packages(build_config.get('packages', 'external')),
            build_config.get('packages', 'internal')
        ])

        bld(features='subst',
            source = 'lib.pc.in',
            target = '%s-%s.pc' % (lib, bld.env.API_VERSION),
            NAME = lib,
            GIR_NAME = gir_name,
            DESCRIPTION = build_config.get('default', 'description'),
            PACKAGES = packages,
            install_path = '${LIBDIR}/pkgconfig')

    for exe in get_dirs('src/bin'):
        exe_dir = path_join('src/bin', exe)
        build_config = ConfigParser.SafeConfigParser(default_build_config)
        build_config.read(path_join(exe_dir, 'build.cfg'))

        bld(features='c cprogram',
            target = exe,
            source = bld.path.ant_glob(path_join(exe_dir, '**/*.vala')),
            vapi_dirs = vapi_dirs,
            uselib = build_config.get('packages', 'external'),
            packages = build_config.get('packages', 'external'),
            use = build_config.get('packages', 'internal'))

    for test in get_dirs('tests/lib'):
        test_dir = path_join('tests/lib', test)
        build_config = ConfigParser.SafeConfigParser(default_build_config)
        build_config.read(path_join(test_dir, 'build.cfg'))

        bld(features='c cprogram',
            target = 'lib%s_TESTS' % test,
            source = bld.path.ant_glob('tests/helpers/**/*.vala') +
                     bld.path.ant_glob(path_join(test_dir, '**/*.vala')),
            vapi_dirs = vapi_dirs,
            install_path = False,
            uselib = build_config.get('packages', 'external'),
            packages = build_config.get('packages', 'external'),
            use = build_config.get('packages', 'internal'))

def test(ctx):
    out_dir = out
    env = { 'LD_LIBRARY_PATH': out }
    for test in get_dirs('tests/lib'):
        command = '%s/lib%s_TESTS' % (out_dir, test)
        if ctx.exec_command(command, env=env) != 0:
            raise Errors.WafError('Tests failed')

# vim: set ft=python sw=4 sts=4 et:
