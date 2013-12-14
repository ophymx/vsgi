/* src/lib/vsgi/connection_info.vala
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

public struct AddressPort {
    public string addr;
    public uint16 port;

    public AddressPort.default() {
        addr = "0.0.0.0";
        port = 0;
    }

    public string to_string() {
        return "%s:%s".printf(addr, port.to_string());
    }

    public bool equal(AddressPort other) {
        return addr == other.addr && port == other.port;
    }
}

public struct ConnectionInfo {
    public Scheme scheme;
    public AddressPort remote;
    public AddressPort local;

    public ConnectionInfo.default() {
        scheme = Scheme.HTTP;
        remote = AddressPort.default();
        local  = AddressPort.default();
    }

    public bool equal(ConnectionInfo other) {
        return scheme == other.scheme &&
                remote.equal(other.remote) &&
                local.equal(other.local);
    }

    public string local_url(string? host=null) {
        if (host == null) {
            host = local.addr;
        }
        var builder = new StringBuilder();
        builder.printf("%s://%s", scheme.to_string(), host);
        if (local.port != scheme.default_port()) {
            builder.append_printf(":%u", local.port);
        }
        return builder.str;
    }
}

}
