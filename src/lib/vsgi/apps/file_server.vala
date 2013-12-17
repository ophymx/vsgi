/* src/lib/vsgi/apps/file_server.vala
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
 * An app to serve static files from a given directory.
 */
public class FileServer : Object, Application {

    private string dir;

    /**
     * @param dir Directory to server files from
     */
    public FileServer(string dir = "public") {
        this.dir = dir;
    }

    /**
     * {@inheritDoc}
     */
    public Response call(Request request) {
        var headers = new Gee.HashMap<string, string>();
        InputStreamBody body;

        try {
            bool uncertain;
            var filename = Path.build_filename(dir, request.path_info);
            var content_type = ContentType.guess(filename, null, out uncertain);

            if (uncertain)
                headers["Content-Type"] = "text/plain";
            else
                headers["Content-Type"] = content_type;

            var file = File.new_for_path(filename);
            var file_info = file.query_info("standard::size",
                FileQueryInfoFlags.NONE);
            headers["Content-Length"] = file_info.get_size().to_string();

            body = new InputStreamBody(file.read());
        } catch(Error e) {
            return NotFound.static_call(request);
        }

        return new Response(200, headers, body);
    }
}

}
