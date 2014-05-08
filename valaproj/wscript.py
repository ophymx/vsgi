import errno
from os import path, listdir
from waflib import Errors

from build import BuildConfig
from config import ProjectConfig

PKG_DIR = '.valaproj'

def _listdirs(dir):
    try:
        dirs = [d for d in listdir(dir)
                if path.isdir(path.join(dir, d)) and not d.startswith('.')]
        return sorted(dirs)
    except OSError, e:
        if e.errno == errno.ENOENT:
            return []
        raise

class Project:
    def __init__(self, out):
        self.out = out
        self.config = ProjectConfig()
        self.config.load()

    def name(self):
        return self.config.name()

    def version(self):
        return self.config.version()

    def load_options(self, opt):
        opt.load('compiler_c')
        opt.load('vala')

    def load_configure(self, conf):
        conf.load('compiler_c')
        conf.load('vala')
        conf.find_program('g-ir-compiler', var='GIR_COMPILER')
        for lib in self.config.glib_libs():
            conf.check_cfg(
                package = lib,
                uselib_store = lib ,
                atleast_version = self.config.min_glib_version(),
                args = '--cflags --libs'
            )

        for lib in self.config.libs():
            conf.check_cfg(
                package = lib.name_version,
                uselib_store = lib.name_version,
                atleast_version = lib.min_version,
                args = '--cflags --libs'
            )


    def load_build(self, bld):
        for lib in self.__builds_for('src/lib'):
            self.__load_lib_build_tasks(bld, lib)

        for bin in self.__builds_for('src/bin'):
            self.__load_bin_build_tasks(bld, bin)

        for test in self.__builds_for('tests/lib'):
            self.__load_test_build_tasks(bld, test)

    def load_test(self, ctx):
        env = { 'LD_LIBRARY_PATH': self.out }
        for test in _listdirs('tests/lib'):
            command = '%s/lib%s_TESTS' % (self.out, test)
            if ctx.exec_command(command, env=env) != 0:
                raise Errors.WafError('Tests failed')

    def __builds_for(self, base_dir):
        for name in _listdirs(base_dir):
            yield BuildConfig(base_dir, name, self.config)

    def __load_bin_build_tasks(self, bld, bin):
        bld(
            features     = 'c cprogram',
            source       = bld.path.ant_glob(bin.source_pattern()),
            target       = bin.name,
            vapi_dirs    = self.config.vapi_dirs(),
            uselib       = bin.external_packages(),
            packages     = bin.external_packages(),
            use          = bin.internal_packages(),
        )

    def __load_test_build_tasks(self, bld, test):
        bld(
            features     = 'c cprogram',
            source       = bld.path.ant_glob('tests/helpers/**/*.vala') +
                           bld.path.ant_glob(test.source_pattern()),
            target       = 'lib%s_TESTS' % test.name,
            install_path = False,
            vapi_dirs    = self.config.vapi_dirs(),
            uselib       = test.external_packages(),
            packages     = test.external_packages(),
            use          = test.internal_packages(),
        )

    def __load_lib_build_tasks(self, bld, lib):
        bld(
            features     = 'c cshlib',
            source       = bld.path.ant_glob(lib.source_pattern()),
            target       = lib.name_version(),
            pkg_name     = lib.name,
            gir          = lib.gir_name_version(),
            vapi_dirs    = self.config.vapi_dirs(),
            vnum         = self.config.so_version(),
            uselib       = lib.external_packages(),
            packages     = lib.external_packages(),
            use          = lib.internal_packages(),
        )

        bld(
            after        = lib.name_version(),
            source       = '%s.gir' % lib.gir_name_version(),
            target       = '%s.typelib' % lib.gir_name_version(),
            install_path = '${LIBDIR}/girepository-1.0',
            rule         = '${GIR_COMPILER} ${SRC} -o ${TGT}',
        )

        bld(
            features     = 'subst',
            source       = path.join(PKG_DIR, 'lib.pc.in'),
            target       = '%s.pc' % lib.name_version(),
            install_path = '${LIBDIR}/pkgconfig',
            VERSION      = self.config.version(),
            NAME_VERSION = lib.name_version(),
            GIR_NAME     = lib.gir_name(),
            DESCRIPTION  = lib.description(),
            PACKAGES     = lib.pkg_configs(),
        )
