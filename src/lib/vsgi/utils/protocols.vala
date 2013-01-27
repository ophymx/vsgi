/* utils/protocols.vala
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

public enum Protocol {
    HTTP1_0,
    HTTP1_1;

    public static Protocol? from_string(string protocol) {
        switch (protocol.up()) {
            case "INCLUDED": return HTTP1_0;
            case "HTTP/1.0": return HTTP1_0;
            case "HTTP/1.1": return HTTP1_1;
            default: return null;
        }
    }

    public string to_string() {
        switch (this) {
            case HTTP1_0: return "HTTP/1.0";
            case HTTP1_1: return "HTTP/1.1";
            default: assert_not_reached();
        }
    }
}

}
