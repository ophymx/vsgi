top = '.'
out = 'build'

def options(opt):
    opt.load('compiler_c')
    opt.load('vala')

def configure(conf):
    conf.load('compiler_c')
    conf.load('vala')
    conf.check_cfg(
            package='glib-2.0',
            uselib_store='glib-2.0',
            atleast_version='2.32.0',
            args='--cflags --libs')
    conf.check_cfg(
            package='gobject-2.0',
            uselib_store='gobject-2.0',
            atleast_version='2.32.0',
            args='--cflags --libs')
    conf.check_cfg(
            package='gio-2.0',
            uselib_store='gio-2.0',
            atleast_version='2.32.0',
            args='--cflags --libs')
    conf.check_cfg(
            package='gmodule-2.0',
            uselib_store='gmodule-2.0',
            atleast_version='2.32.0',
            args='--cflags --libs')
    conf.check_cfg(
            package='gee-1.0',
            uselib_store='gee-1.0',
            atleast_version='0.6.0',
            args='--cflags --libs')

    conf.check(
            fragment='#include <fastcgi.h>\nint main(){return 0;}\n',
            lib = 'fcgi',
            uselib_store = 'fcgi',
            mandatory=1,
            msg='checking for libfcgi')

    import yaml
    version_config = yaml.load(file('version.yml', 'r'))
    version_config.setdefault('version', [0, 0, 1])
    version_config.setdefault('api_version', [1, 0])

    conf.env['VERSION']     = ".".join(map(lambda x: str(x),
                                           version_config['version']))
    conf.env['API_VERSION'] = ".".join(map(lambda x: str(x),
                                           version_config['api_version']))
    conf.env['SO_VERSION']  = ".".join(map(lambda x: str(x),
                                           version_config['version'][:3]))

def build(bld):
    import os
    import yaml

    libs = [lib for lib in os.listdir('src/lib') if not lib.startswith('.')]
    # FIXME: sorting libs here to keep dependency order. Just so happens to be
    #        correct for this project. Need to patch upstream so that vala 'use'
    #        can be evaluated later (after all tasks are defined).
    for lib in sorted(libs):
        build_config = yaml.load(file('src/lib/%s/.build.yml' % lib, 'r'))

        build_config.setdefault('packages', {})
        build_config['packages'].setdefault('internal', [])
        build_config['packages'].setdefault('external', [])

        packages = build_config['packages']['internal'] + \
                   build_config['packages']['external']

        bld(features='c cshlib',
            target = '%s-%s' % (lib, bld.env.API_VERSION),
            pkg_name = lib,
            source = bld.path.ant_glob('src/lib/%s/**/*.vala' % lib),
            gir = '%s-%s' % (build_config['gir_name'], bld.env.API_VERSION),
            vapi_dirs = ['.', 'vapi'],
            uselib = build_config['packages']['external'][:],
            packages = build_config['packages']['external'][:],
            vnum = bld.env.SO_VERSION,
            use = build_config['packages']['internal'][:])

        bld(features='subst',
            source = 'src/lib/%s/%s.pc.in' % (lib, lib),
            target = '%s-%s.pc' % (lib, bld.env.API_VERSION),
            install_path = '${LIBDIR}/pkgconfig')

    execs = [exe for exe in os.listdir('src/bin') if not exe.startswith('.')]
    for exe in execs:
        build_config = yaml.load(file('src/bin/%s/.build.yml' % exe, 'r'))
        build_config.setdefault('packages', {})
        build_config['packages'].setdefault('internal', [])
        build_config['packages'].setdefault('external', [])

        packages = build_config['packages']['internal'] + \
                   build_config['packages']['external']

        bld(features='c cprogram',
            target = exe,
            source = bld.path.ant_glob('src/bin/%s/**/*.vala' % exe),
            vapi_dirs = ['.', 'vapi'],
            uselib = build_config['packages']['external'][:],
            packages = build_config['packages']['external'][:],
            use = build_config['packages']['internal'][:])

    lib_tests = [t for t in os.listdir('tests/lib') if not t.startswith('.')]
    for test in lib_tests:
        build_config = yaml.load(file('tests/lib/%s/.build.yml' % test, 'r'))
        build_config.setdefault('packages', {})
        build_config['packages'].setdefault('internal', [])
        build_config['packages'].setdefault('external', [])

        packages = build_config['packages']['internal'] + \
                   build_config['packages']['external']

        bld(features='c cprogram',
            target = 'lib%s_TESTS' % test,
            source = bld.path.ant_glob('tests/helpers/**/*.vala') +
                     bld.path.ant_glob('tests/lib/%s/**/*.vala' % test),
            vapi_dirs = ['.', 'vapi'],
            uselib = build_config['packages']['external'][:],
            packages = build_config['packages']['external'][:],
            use = build_config['packages']['internal'][:])

def test(ctx):
    pass

# vim: set ft=python sw=4 sts=4 et:
