/* tests/lib/vsgi/apps/mapper_tests.vala
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
public class MapperAppTests : CompositeAppTests {

    public MapperAppTests() {
        base("Mapper");
    }

    protected Gee.Map<string, VSGI.Application> test_map;


    public override void set_up() {
        base.set_up();
        test_map = new Gee.HashMap<string, VSGI.Application>();
        test_compositeapp = new VSGI.Mapper.Composite(test_map);
    }


}
