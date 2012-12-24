VSGI.Request mock_request() {
    Gee.HashMap<string, string> headers = new Gee.HashMap<string, string>();
    headers["User-Agent"] = "Mock Agent";
    headers["Host"] = "myhost";
    headers["Accept"] = "*/*";

    VSGI.Body body = new VSGI.Body.empty();
    return new VSGI.Request(
        VSGI.Method.GET,
        "/foo",
        "/bar/",
        "foo1=bar1&foo2=bar2",
        "10.0.0.2",
        42222,
        "10.0.1.2",
        8080,
        VSGI.Protocol.HTTP1_1,
        VSGI.Scheme.HTTP,
        headers,
        body
    );
}

public class MockRequest {
    public MockRequest() {

    }
}
