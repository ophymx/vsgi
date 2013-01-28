/* File exists to help with valadoc with older vala drivers */
[Compact]
public class Bytes {
    public Bytes(uint8[] data);
    public size_t length;
    public uint8[] get_data();
    public size_t get_size ();
}

[Compact]
public class DataInputStream : GLib.InputStream {
    public DataInputStream(GLib.InputStream input);
    public void set_newline_type(GLib.DataStreamNewlineType newline);
    public string read_line_utf8(out size_t size);

}

