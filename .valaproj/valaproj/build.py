import ConfigParser
from os import path
from subprocess import call

class BuildConfig:
    def __init__(self, base_dir, name, project_config):
        self.base_dir = base_dir
        self.name = name
        self.project_config = project_config
        default_build_config = {
            'external': '',
            'internal': '',
            'description': ''
        }
        self.build_parser = ConfigParser.SafeConfigParser(default_build_config)
        self.build_parser.read(path.join(base_dir, name, 'build.cfg'))

    def name_version(self):
        return '%s-%s' % (self.name, self.project_config.api_version())

    def gir_name(self):
        return self.build_parser.get('default', 'gir_name')

    def gir_name_version(self):
        return '%s-%s' % (self.gir_name(), self.project_config.api_version())

    def description(self):
        return self.build_parser.get('default', 'description')

    def external_packages(self):
        return self.build_parser.get('packages', 'external')

    def internal_packages(self):
        return self.build_parser.get('packages', 'internal')

    def packages(self):
        return '%s %s' % (self.internal_packages(), self.external_packages())

    def pkg_configs(self):
        pkgs = [pkg for pkg in self.packages().split()
                if call(['pkg-config', pkg]) == 0]
        return ' '.join(pkgs)

    def source_pattern(self):
        return path.join(self.base_dir, self.name, '**', '*.vala')
