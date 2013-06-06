/* lib/vsgi/response.vala
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

    public signal void headers_sent();

    public signal void body_sent();

    /**
     *
     */
    public Status status { get; private set; }

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
        this.status = Status(status);
        if (headers == null)
            this.headers = new Gee.HashMap<string, string>();
        else
            this.headers = (!) headers;
        if (body == null)
            this.body = new Body.empty();
        else
            this.body = (!) body;
    }

    public Response.simple(uint status, string body) {
        this.status = Status(status);
        this.headers = new Gee.HashMap<string, string>();
        this.body = new Body.from_string(body);

        headers["Content-Type"] = "text/plain";
        headers["Content-Length"] = body.length.to_string();
    }

    public ssize_t content_length() {
        ssize_t length = -1;
        if (headers.has_key("Content-Length"))
            headers["Content-Length"].scanf("%" + ssize_t.FORMAT, &length);
        return length;
    }

    /**
     *
     */
    public bool validate() throws InvalidResponse {
        if (!status.is_valid())
            throw new InvalidResponse.INVALID_STATUS_CODE(
                @"status code '$status' is invalid");

        if (status.has_entity()) {
            if (!headers.has_key("Content-Type"))
                throw new InvalidResponse.MISSING_CONTENT_TYPE(
                    "Content-Type header must be set for status code " +
                        @"'$status'");
        } else {
            if (headers.has_key("Content-Type"))
                throw new InvalidResponse.HAS_CONTENT_TYPE(
                    "Content-Type header must not be set with status code " +
                        @"'$status'");

            if (headers.has_key("Content-Length"))
                throw new InvalidResponse.HAS_CONTENT_LENGTH(
                    "Content-Length header must not be set with status code " +
                        @"'$status'");
        }

        if (headers.has_key("Status"))
            throw new InvalidResponse.INVALID_HEADER(
                "must not set header of 'Status'");

        foreach (var header_key in headers.keys) {
            if (header_key.has_suffix("-") | header_key.has_suffix("_"))
                throw new InvalidResponse.INVALID_HEADER(
                    "header key must not end with '-' or '_'");

            if (":" in header_key)
                throw new InvalidResponse.INVALID_HEADER(
                    "header key must not contain ':'");

            if ("\n" in header_key)
                throw new InvalidResponse.INVALID_HEADER(
                    "header key must not contain a newline");
        }
        return true;
    }
}

}
