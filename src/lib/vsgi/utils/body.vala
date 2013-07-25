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
public class Body : Object, Gee.Iterable<Bytes> {

    private Bytes body;

    public Type element_type { get { return typeof(Bytes); } }

    /**
     *
     */
    public Body(Bytes body) {
        this.body = body;
    }

    /**
     * Converts given string to Bytes and wraps it.
     * @param body string of response/request
     */
    public Body.from_string(string body) {
        this.body = new Bytes(body.data);
    }

    /**
     * Creates an empty body that is still a valid Iterable<Bytes> object.
     */
    public Body.empty() {
        body = new Bytes({});
    }

    public Gee.Iterator<Bytes> iterator() {
        return new BodyIter(body);
    }

}

/**
 *
 */
public class BodyIter : Object, Gee.Iterator<Bytes> {

    private enum State {
        INIT,
        ON_TRACK,
        END,
        OFF_TRACK;
    }

    private Bytes body;
    private State state;

    public BodyIter(Bytes body) {
        this.body = body;
        state = State.INIT;
    }

    public bool next() {
        if (state == State.INIT) {
            state = State.ON_TRACK;
            return true;
        } else {
            if (state == State.ON_TRACK)
                state = State.END;
            return false;
        }
    }

    public bool has_next() {
        return state == State.INIT;
    }

    public bool first() {
        state = State.ON_TRACK;
        return true;
    }

    public new Bytes get() {
        assert(state == State.ON_TRACK);
        return body;
    }

    public void remove() {
        state = State.OFF_TRACK;
    }

}

}
