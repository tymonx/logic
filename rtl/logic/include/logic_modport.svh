/* Copyright 2018 Tymoteusz Blazejczyk
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`ifndef LOGIC_MODPORT_SVH
`define LOGIC_MODPORT_SVH

`ifndef LOGIC_MODPORT_DISABLED
    /* Define: LOGIC_MODPORT
     *
     * Define that helps to enable or disable modport feature. Useful only for Intel
     * Quartus Pro Prime that doesn't support modports properly.
     *
     * Parameters:
     *  _interface  - Interface name.
     *  _modport    - Modport name.
     */
    `define LOGIC_MODPORT(_interface, _modport) \
        _interface.``_modport
`else
    `define LOGIC_MODPORT(_interface, _modport) \
        _interface
`endif

`endif /* LOGIC_MODPORT_SVH */
