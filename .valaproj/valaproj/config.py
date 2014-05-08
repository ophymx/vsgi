import ConfigParser
from pprint import pprint

class LibDefinition:
    def __init__(self, definition):
        self.name_version, self.min_version  = definition.split(':')

class ProjectConfig:
    def __init__(self):
        default_project_config = {
            'version': '0.0.1',
            'api_version': '0.1',
            'min_glib_version': '2.32.0',
            'glib_libs': 'glib-2.0 gobject-2.0 gio-2.0',
            'libs': ''
        }
        self.config = ConfigParser.SafeConfigParser(default_project_config)

    def load(self):
        self.config.read('version.cfg')

    def name(self):
        return self.config.get('default', 'name')

    def version(self):
        return self.config.get('default', 'version')

    def api_version(self):
        return self.config.get('default', 'api_version')

    def so_version(self):
        return '.'.join(self.version().split('.')[:2])

    def vapi_dirs(self):
        return ['.', 'vapi']

    def min_glib_version(self):
        return self.config.get('default', 'min_glib_version')

    def glib_libs(self):
        return self.config.get('default', 'glib_libs').split()


    def libs(self):
        for definition in self.config.get('default', 'libs').split():
            yield LibDefinition(definition)
