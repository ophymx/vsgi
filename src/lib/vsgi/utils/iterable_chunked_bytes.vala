/* lib/vsgi/utils/iterable_chunked_bytes.vala
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
public class IterableChunkedBytes : Object, Gee.Iterable<Bytes> {

    private Gee.Iterable<Bytes> chunks;

    public Type element_type { get { return typeof(Bytes); } }

    /**
     *
     */
    public IterableChunkedBytes(Gee.Iterable<Bytes> chunks) {
        this.chunks = chunks;
    }

    public Gee.Iterator<Bytes> iterator(){
        return new ChunkedBytesIter(chunks.iterator());
    }

}

/**
 *
 */
public class ChunkedBytesIter : Object, Gee.Iterator<Bytes> {

    private const uint8[] TAIL = {'0', '\r', '\n', '\r', '\n'};
    private const uint8[] TERM = {'\r', '\n'};
    private const uint8[] ZLEN = {};

    private enum State {
        PROCESSING,
        LAST,
        FINISHED
    }

    private Gee.Iterator<Bytes> chunks_iter;
    private State state = State.PROCESSING;

    /**
     *
     */
    public ChunkedBytesIter(Gee.Iterator<Bytes> chunks_iter) {
        this.chunks_iter = chunks_iter;
    }

    public bool next() {
        switch (state) {
            case State.PROCESSING:
                if (!chunks_iter.next())
                    state = State.LAST;
                return true;
            case State.LAST:
                state = State.FINISHED;
                return false;
            case State.FINISHED:
                return false;
            default:
                return false;
        }
    }

    public bool has_next() {
        return (state != State.FINISHED);
    }

    public bool first() {
        state = State.PROCESSING;
        return chunks_iter.first();
    }

    public new Bytes get() {
        switch (state) {
            case State.PROCESSING:
                Bytes chunk = chunks_iter.get();
                size_t size = chunk.get_size();
                /* Skip empty bytes since this finishes the chunked stream */
                if (size == 0 && chunks_iter.has_next()) {
                    next();
                    return get();
                }
                /* size of chunk + 16 for size string + 4 for line breaks */
                ByteArray bytes = new ByteArray.sized((uint)size + 16 + 4);
                bytes.append(size_to_hex(size).data);
                bytes.append(TERM);
                bytes.append(chunk.get_data());
                bytes.append(TERM);

                return ByteArray.free_to_bytes((owned) bytes);
            case State.LAST:
                return new Bytes.static(TAIL);
            case State.FINISHED:
                return new Bytes.static(ZLEN);
            default:
                assert_not_reached();
        }
    }

    private static string size_to_hex(size_t size) {
        return size.to_string("%" + size_t.FORMAT_MODIFIER + "x");
    }

    public void remove() {
        if (state == State.PROCESSING)
            chunks_iter.remove();
    }
}

}
