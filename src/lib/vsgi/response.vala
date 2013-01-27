/* response.vala
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

public errordomain InvalidResponse {
    HAS_CONTENT_TYPE,
    HAS_CONTENT_LENGTH,
    MISSING_CONTENT_TYPE,
    INVALID_STATUS_CODE,
    INVALID_HEADER
}

/**
 * Response returned from a call to a {@link VSGI.Application}
 */
public class Response : Object {
    private uint _status;

    public signal void headers_sent();
    public signal void body_sent();

    /**
     *
     */
    public uint status {
        get { return _status; }
        private set { _status = value; }
    }

    /**
     *
     */
    public Gee.Map<string, string> headers;

    /**
     *
     */
    public Gee.Iterable<Bytes> body;

    /**
     *
     */
    public Response(uint status, Gee.Map<string, string>? headers=null,
        Gee.Iterable<Bytes>? body=null) {
        this.status = status;
        if (headers == null)
            this.headers = new Gee.HashMap<string, string>();
        else
            this.headers = (!) headers;
        if (body == null)
            this.body = new Body.empty();
        else
            this.body = (!) body;
    }

    /**
     *
     */
    public bool validate() throws InvalidResponse {
        if (status < 100 | status > 599)
            throw new InvalidResponse.INVALID_STATUS_CODE(
                "status code '%u' is invalid".printf(status));

        if (Utils.status_has_entity(status)) {
            if (headers.has_key("Content-Type"))
                throw new InvalidResponse.HAS_CONTENT_TYPE(
                    "Content-Type header must not be set with " +
                    "status code %u".printf(status));

            if (headers.has_key("Content-Length"))
                throw new InvalidResponse.HAS_CONTENT_LENGTH(
                    "Content-Length header must not be set with " +
                    "status code %u".printf(status));
        } else {
            if (!headers.has_key("Content-Type"))
                throw new InvalidResponse.MISSING_CONTENT_TYPE(
                    "Content-Type header must be set for " +
                    "status code '%u'".printf(status));
        }

        foreach (var header_key in headers.keys) {
            if (header_key == "Status")
                throw new InvalidResponse.INVALID_HEADER(
                    "must not set header of 'Status'");
            if (header_key[header_key.length - 1] == '-' |
                header_key[header_key.length - 1] == '_')
                throw new InvalidResponse.INVALID_HEADER(
                    "header key must not end with '-' or '_'");

            if (header_key.index_of_char(':') >= 0)
                throw new InvalidResponse.INVALID_HEADER(
                    "header key must not contain ':'");

            if (header_key.index_of_char('\n') >= 0)
                throw new InvalidResponse.INVALID_HEADER(
                    "header key must not contain a newline");
        }
        return true;
    }
}

}
