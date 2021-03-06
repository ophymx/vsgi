/* src/lib/vsgi/utils/iterable_chunked_bytes.vala
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
public class ChunkedBody : Object, Body {

    private Body chunks;

    /**
     *
     */
    public ChunkedBody(Body chunks) {
        this.chunks = chunks;
    }

    public BodyIterator iterator(){
        return new ChunkedBodyIterator(chunks.iterator());
    }

}

/**
 *
 */
public class ChunkedBodyIterator : Object, BodyIterator {

    private const uint8[] TAIL = {'0', '\r', '\n', '\r', '\n'};
    private const uint8[] TERM = {'\r', '\n'};
    private const uint8[] ZLEN = {};

    private enum State {
        INIT,
        LAST,
        END
    }

    private BodyIterator chunks_iter;
    private State state = State.INIT;

    /**
     *
     */
    public ChunkedBodyIterator(BodyIterator chunks_iter) {
        this.chunks_iter = chunks_iter;
    }

    public bool next() {
        switch (state) {
            case State.INIT:
                if (chunks_iter.next()) {
                    if (get().get_size() == 0) {
                        return next();
                    }
                } else {
                    state = State.LAST;
                }
                return true;
            case State.LAST:
                state = State.END;
                return false;
            case State.END:
                return false;
            default:
                return false;
        }
    }

    public new Bytes @get() {
        switch (state) {
            case State.INIT:
                var chunk = chunks_iter.get();
                var size = chunk.get_size();
                /* size of chunk + 16 for size string + 4 for line breaks */
                var bytes = new ByteArray.sized((uint) size + 16 + 4);
                bytes.append(size_to_hex(size).data);
                bytes.append(TERM);
                bytes.append(chunk.get_data());
                bytes.append(TERM);

                return ByteArray.free_to_bytes((owned) bytes);
            case State.LAST:
                return new Bytes.static(TAIL);
            case State.END:
                return new Bytes.static(ZLEN);
            default:
                assert_not_reached();
        }
    }

    private static string size_to_hex(size_t size) {
        return size.to_string("%" + size_t.FORMAT_MODIFIER + "x");
    }

}

}
