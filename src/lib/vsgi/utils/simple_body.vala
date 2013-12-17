/* src/lib/vsgi/utils/body.vala
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
 * A fairly simple wrapper class for holding the body of a response/request
 */
public class SimpleBody : Object, Body {

    private Bytes body;

    /**
     *
     */
    public SimpleBody(Bytes body) {
        this.body = body;
    }

    /**
     * Converts given string to Bytes and wraps it.
     * @param body string of response/request
     */
    public SimpleBody.from_string(string body) {
        this.body = new Bytes(body.data);
    }

    /**
     * Creates an empty body that is still a valid Iterable<Bytes> object.
     */
    public SimpleBody.empty() {
        body = new Bytes({});
    }

    public BodyIterator iterator() {
        return new Iterator(body);
    }

    public class Iterator : Object, BodyIterator {
        private Bytes body;
        private bool consumed = false;


        public Iterator(Bytes body) {
            this.body = body;
        }

        public  bool next() {
            return consumed ? false : consumed = true;
        }

        public new Bytes @get() {
            return body;
        }
    }
}


}
