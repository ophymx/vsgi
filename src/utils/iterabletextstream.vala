using Gee;
namespace VSGI {

public class IterableTextStream : Object, Iterable<string> {

    private InputStream input_stream;

    public Type element_type { get { return typeof(string); } }

    public IterableTextStream(InputStream input_stream) {
        this.input_stream = input_stream;
    }

    public Iterator<string> iterator(){
        return new TextStreamIter(input_stream);
    }

}

public class TextStreamIter : Object, Iterator<string> {

    //private const int BUFFER_SIZE = 65536;
    private const int BUFFER_SIZE = 16384;

    private InputStream input_stream;
    private size_t current_chunk_size = 0;
    private size_t next_chunk_size = 0;
    private size_t collected = 0;
    private uint8[] current_chunk = new uint8[BUFFER_SIZE];
    private uint8[] next_chunk = new uint8[BUFFER_SIZE];

    public class TextStreamIter(InputStream input_stream) {
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
                input_stream.close();
                return false;
            }
            if (!next()) {
                input_stream.close();
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

    public new string get() {
        if (current_chunk_size != BUFFER_SIZE)
            return ((string) current_chunk).substring(0, (long) current_chunk_size);
        else
            return (string) current_chunk;
    }

    public void remove() {
        return;
    }
}

}
