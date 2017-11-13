/* Copyright 2017 Tymoteusz Blazejczyk
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * @copyright
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`ifndef LOGIC_MODPORT_SVH
`define LOGIC_MODPORT_SVH

`ifndef LOGIC_MODPORT_DISABLED
    `define logic_modport(_interface, _modport) _interface.``_modport
`else
    `define logic_modport(_interface, _modport) _interface
`endif

`endif /* LOGIC_MODPORT_SVH */
