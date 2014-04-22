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
namespace ServerMain {

    private static Server server;

    private const ProcessSignal[] STOP_SIGNALS = {
        ProcessSignal.TERM,
        ProcessSignal.INT,
        ProcessSignal.QUIT
    };

    private const string[] LOG_DOMAINS = {
        "VSGI.CommonLogger",
        "VSGI.SimpleServer",
        "VSGI.Lint"
    };

    private static void stdout_logfunc(string? domain, LogLevelFlags levels,
        string message) {
        stdout.printf("%s\n", message);
    }

    public static int run(Server s) {
        server = s;
        foreach (var domain in LOG_DOMAINS) {
            Log.set_handler(domain, LogLevelFlags.LEVEL_MASK, stdout_logfunc);
        }

        foreach (var signum in STOP_SIGNALS) {
            Process.signal(signum, (s) => { server.stop(); });
        }

        server.start();
        return 0;
    }
}

}
