import ConfigParser

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

    version_config = ConfigParser.SafeConfigParser({
        'version': '0.0.1',
        'api_version': '1.0'
    })
    version_config.read('version.cfg')

    version = version_config.get('default', 'version')
    conf.env['VERSION']     = version
    conf.env['API_VERSION'] = version_config.get('default', 'api_version')
    conf.env['SO_VERSION']  = '.'.join(version.split('.')[:2])

def build(bld):
    import os
    def get_packages(config_parser):
        if not config_parser.has_section('packages'):
            config_parser.add_section('packages')
        if not config_parser.has_option('packages', 'internal'):
            config_parser.set('packages', 'internal', '')
        if not config_parser.has_option('packages', 'external'):
            config_parser.set('packages', 'external', '')
        return (config_parser.get('packages', 'external'),
                config_parser.get('packages', 'internal'))

    vapi_dirs = ['.', 'vapi']

    libs = [lib for lib in os.listdir('src/lib') if not lib.startswith('.')]
    # FIXME: sorting libs here to keep dependency order. Just so happens to be
    #        correct for this project. Need to patch upstream so that vala 'use'
    #        can be evaluated later (after all tasks are defined).
    for lib in sorted(libs):
        build_config = ConfigParser.SafeConfigParser()
        build_config.read('src/lib/%s/build.cfg' % lib)
        external_pkgs, internal_pkgs = get_packages(build_config)

        bld(features='c cshlib',
            target = '%s-%s' % (lib, bld.env.API_VERSION),
            pkg_name = lib,
            source = bld.path.ant_glob('src/lib/%s/**/*.vala' % lib),
            gir = '%(gir_name)s-%(api_version)s' % {
                'gir_name': build_config.get('default', 'gir_name'),
                'api_version': bld.env.API_VERSION
            },
            vapi_dirs = vapi_dirs,
            vnum = bld.env.SO_VERSION,
            uselib = external_pkgs,
            packages = external_pkgs,
            use = internal_pkgs)

        bld(features='subst',
            source = 'src/lib/%s/%s.pc.in' % (lib, lib),
            target = '%s-%s.pc' % (lib, bld.env.API_VERSION),
            install_path = '${LIBDIR}/pkgconfig')

    execs = [exe for exe in os.listdir('src/bin') if not exe.startswith('.')]
    for exe in execs:
        build_config = ConfigParser.SafeConfigParser()
        build_config.read('src/bin/%s/build.cfg' % exe)
        external_pkgs, internal_pkgs = get_packages(build_config)

        bld(features='c cprogram',
            target = exe,
            source = bld.path.ant_glob('src/bin/%s/**/*.vala' % exe),
            vapi_dirs = vapi_dirs,
            uselib = external_pkgs,
            packages = external_pkgs,
            use = internal_pkgs)

    lib_tests = [t for t in os.listdir('tests/lib') if not t.startswith('.')]
    for test in lib_tests:
        build_config = ConfigParser.SafeConfigParser()
        build_config.read('tests/lib/%s/build.cfg' % test)
        external_pkgs, internal_pkgs = get_packages(build_config)

        bld(features='c cprogram',
            target = 'lib%s_TESTS' % test,
            source = bld.path.ant_glob('tests/helpers/**/*.vala') +
                     bld.path.ant_glob('tests/lib/%s/**/*.vala' % test),
            vapi_dirs = vapi_dirs,
            uselib = external_pkgs,
            packages = external_pkgs,
            use = internal_pkgs)

def test(ctx):
    pass

# vim: set ft=python sw=4 sts=4 et:
