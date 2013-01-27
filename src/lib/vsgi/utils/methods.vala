/* utils/methods.vala
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

public enum Method {
    OPTIONS,
    GET,
    HEAD,
    POST,
    PUT,
    DELETE,
    TRACE,
    CONNECT,
    PATCH;

    public static Method? from_string(string method) {
        switch (method.up()) {
            case "OPTIONS": return OPTIONS;
            case "GET":     return GET;
            case "HEAD":    return HEAD;
            case "POST":    return POST;
            case "PUT":     return PUT;
            case "DELETE":  return DELETE;
            case "TRACE":   return TRACE;
            case "CONNECT": return CONNECT;
            case "PATCH":   return PATCH;
            default: return null;
        }
    }

    public string to_string() {
        switch (this) {
            case OPTIONS: return "OPTIONS";
            case GET:     return "GET";
            case POST:    return "POST";
            case PUT:     return "PUT";
            case DELETE:  return "DELETE";
            case TRACE:   return "TRACE";
            case CONNECT: return "CONNECT";
            case PATCH:   return "PATCH";
            default: assert_not_reached();
        }
    }
}

}
