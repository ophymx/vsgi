namespace VSGI {

public class IterableBytesBody : Object, Body {
    private Gee.Iterable<Bytes> body;

    public IterableBytesBody(Gee.Iterable<Bytes> body) {
        this.body = body;
    }

    public BodyIterator iterator() {
        return new Iterator(body.iterator());
    }

    private class Iterator : Object, BodyIterator {
        private Gee.Iterator<Bytes> iterator;

        public Iterator(Gee.Iterator<Bytes> iterator) {
            this.iterator = iterator;
        }

        public bool next() {
            return iterator.next();
        }

        public new Bytes @get() {
            return iterator.get();
        }
    }
}

}
