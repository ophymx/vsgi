namespace VSGI {

public abstract class IterableBytes : Object, Gee.Traversable<Bytes> {
    public abstract Gee.Iterator<Bytes> iterator();

    public bool @foreach(Gee.ForallFunc<Bytes> f) {
        foreach(var bytes in this) {
            if (!f(bytes)) {
                return false;
            }
        }
        return true;
    }
}

public abstract class BytesIterator : Object, Gee.Traversable<Bytes> {
    public abstract bool next();
    public abstract new Bytes @get();

    public bool read_only { get { return true; }}

    public bool @foreach(Gee.ForallFunc<Bytes> f) {
        while (next()) {
            if (!f(get())) {
                return false;
            }
        }
        return true;
    }
}

}
