/* lib/vsgi/utils/iterable_byte_stream.vala
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
public class IterableByteStream : Object, Gee.Iterable<Bytes> {

    private InputStream input_stream;

    public Type element_type { get { return typeof(Bytes); } }

    /**
     *
     */
    public IterableByteStream(InputStream input_stream) {
        this.input_stream = input_stream;
    }

    public Gee.Iterator<Bytes> iterator(){
        return new ByteStreamIter(input_stream);
    }

}

/**
 *
 */
public class ByteStreamIter : Object, Gee.Iterator<Bytes> {

    private const int BUFFER_SIZE = 65536;

    private InputStream input_stream;
    private size_t collected = 0;
    private Bytes current_chunk;
    private Bytes next_chunk;

    /**
     *
     */
    public ByteStreamIter(InputStream input_stream) {
        this.input_stream = input_stream;
        current_chunk = new Bytes({});
        next_chunk = new Bytes({});
    }

    public bool next() {
        current_chunk = next_chunk;
        try {
            next_chunk = input_stream.read_bytes(BUFFER_SIZE);
            collected += next_chunk.get_size();
        } catch(Error e) {
            log("vsgi", LogLevelFlags.LEVEL_ERROR, "%s", e.message);
        }
        if (current_chunk.get_size() <= 0) {
            if (next_chunk.get_size() <= 0 ) {
                try {
                    input_stream.close();
                } catch(Error e) {
                    log("vsgi", LogLevelFlags.LEVEL_ERROR, "%s", e.message);
                }
                return false;
            }
            if (!next()) {
                try {
                    input_stream.close();
                } catch(Error e) {
                    log("vsgi", LogLevelFlags.LEVEL_ERROR, "%s", e.message);
                }
                return false;
            }
        }
        return (current_chunk.get_size() > 0);
    }

    public bool has_next() {
        return (next_chunk.get_size() > 0);
    }

    public bool first() {
        return false;
    }

    public new Bytes get() {
        return current_chunk;
    }

    public void remove() {
        return;
    }
}

}
