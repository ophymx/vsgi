/* src/lib/vsgi/server.vala
 *
 * Copyright (C) 2012 Jeffrey T. Peckham
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 *      Jeffrey T. Peckham <abic@ophymx.com>
 */
namespace VSGI {

/**
 *
 */
public errordomain AppLoadError {
    FILE_NOT_FOUND,
    MODULE_OPEN,
    SYMBOL_NOT_FOUND,
    SETUP_RETURNED_NULL
}

public errordomain ParseRequestError {
    UNSUPPORTED_METHOD,
    UNSUPPORTED_PROTOCOL,
    INVALID_URL
}

/**
 *
 */
public abstract class Server {

    protected static const string SETUP_FUNC = "setup_app";

    /**
     *
     */
    protected delegate Application AppSetupFunc(Server server);

    protected Application app;

    public Server() {
    }

    /**
     * Start server
     */
    public abstract void start();

    /**
     * Stop server
     */
    public abstract void stop();

    /**
     * Loads app into server from externally defined setup_app()
     *
     * @param setup_file path to shard object with setup_app() defined
     * @throws AppLoadError Errors from loading app
     * @return true if successfully loaded
     */
    public bool load_app(string setup_file) throws AppLoadError {
        Module module = Module.open(setup_file, ModuleFlags.BIND_MASK);

        if (module == null) {
            throw new AppLoadError.MODULE_OPEN(
                "Failed to load setup file '%s': %s", setup_file,
                Module.error());
        }

        void* function;

        if (!module.symbol(SETUP_FUNC, out function)) {
            throw new AppLoadError.SYMBOL_NOT_FOUND(
                "Failed to find function '%s' in '%s': %s", SETUP_FUNC,
                setup_file, Module.error());
        }

        app = ((AppSetupFunc) function)(this);
        if (app == null) {
            throw new AppLoadError.SETUP_RETURNED_NULL("'%s' returned null",
                SETUP_FUNC);
        }

        log("vsgi", LogLevelFlags.LEVEL_DEBUG, "loaded '%s' app",
            app.get_type().name());

        return true;
    }
}

}
