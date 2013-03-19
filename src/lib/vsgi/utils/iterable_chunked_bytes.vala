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
    public IterableChunkedBytes(Gee.Iterable chunks) {
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
                /* Skip empty bytes since this finishes the chunked stream */
                if (chunk.get_size() == 0 && chunks_iter.has_next()) {
                    this.next();
                    return this.get();
                }
                return new Bytes("%s\r\n%s\r\n".printf(
                        chunk.get_size().to_string("%x"),
                        (string) chunk.get_data()).data);
            case State.LAST:
                return new Bytes({'0', '\r', '\n', '\r', '\n'});
            case State.FINISHED:
                return new Bytes({});
            default:
                return new Bytes({});
        }
    }

    public void remove() {
        if (state == State.PROCESSING) {
            chunks_iter.remove();
        }
    }
}

}
