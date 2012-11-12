using Gee;
namespace VSGI {

/**
 * A fairly simple wrapper class for holding the body of a response/request
 */
public class Body : Object, Iterable<Bytes> {

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
        this.body = new Bytes({});
    }

    public Iterator<Bytes> iterator() {
        return new BodyIter(body);
    }

}

/**
 *
 */
public class BodyIter : Object, Iterator<Bytes> {

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
        this.state = State.INIT;
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
