using Gee;
namespace VSGI {

/**
 *
 */
public class IterableByteStream : Object, Iterable<Bytes> {

    private InputStream input_stream;

    public Type element_type { get { return typeof(Bytes); } }

    /**
     *
     */
    public IterableByteStream(InputStream input_stream) {
        this.input_stream = input_stream;
    }

    public Iterator<Bytes> iterator(){
        return new ByteStreamIter(input_stream);
    }

}

/**
 *
 */
public class ByteStreamIter : Object, Iterator<Bytes> {

    private const int BUFFER_SIZE = 65536;

    private InputStream input_stream;
    private size_t current_chunk_size = 0;
    private size_t next_chunk_size = 0;
    private size_t collected = 0;
    private uint8[] current_chunk = new uint8[BUFFER_SIZE];
    private uint8[] next_chunk = new uint8[BUFFER_SIZE];

    /**
     *
     */
    public ByteStreamIter(InputStream input_stream) {
        this.input_stream = input_stream;
    }

    public bool next() {
        current_chunk = next_chunk;
        current_chunk_size = next_chunk_size;
        try {
            next_chunk_size = input_stream.read(next_chunk);
            collected += next_chunk_size;
        } catch(Error e) {
            stderr.printf("%s\n", e.message);
        }
        if (current_chunk_size < 1) {
            if (next_chunk_size < 1 ) {
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
        return (current_chunk_size > 0);
    }

    public bool has_next() {
        return (next_chunk_size > 0);
    }

    public bool first() {
        return false;
    }

    public new Bytes get() {
        if (current_chunk_size != BUFFER_SIZE)
            return new Bytes(current_chunk[0:current_chunk_size]);
        else
            return new Bytes(current_chunk);
    }

    public void remove() {
        return;
    }
}

}
