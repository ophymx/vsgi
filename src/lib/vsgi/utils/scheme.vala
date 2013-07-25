/* src/lib/vsgi/utils/scheme.vala
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

public enum Scheme {
    HTTP,
    HTTPS;

    public static Scheme? from_string(string scheme) {
        switch (scheme.down()) {
            case "http":
                return HTTP;

            case "https":
                return HTTPS;

            default:
                return null;
        }
    }

    public static Scheme? from_port(uint16 port) {
        switch (port) {
            case 80:
                return HTTP;

            case 443:
                return HTTPS;

            default:
                return null;
        }
    }

    public string to_string() {
        switch (this) {
            case HTTP:
                return "http";

            case HTTPS:
                return "https";

            default:
                assert_not_reached();
        }
    }

    public uint16 default_port() {
        switch (this) {
            case HTTP:
                return 80;

            case HTTPS:
                return 443;

            default:
                assert_not_reached();
        }
    }

}

}
