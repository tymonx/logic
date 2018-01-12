/* Copyright 2017 Tymoteusz Blazejczyk
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

`ifndef LOGIC_SVH
`define LOGIC_SVH

`ifndef LOGIC_SYNTHESIS
    `ifdef VERILATOR
        /* Define: LOGIC_SYNTHESIS
         *
         * Enable only synthesizable parts of HDL.
         */
        `define LOGIC_SYNTHESIS
    `endif
`endif

`ifdef LOGIC_SYNTHESIS
    `ifndef LOGIC_STD_OVL_DISABLED
        /* Define: LOGIC_STD_OVL_DISABLED
         *
         * Disable OVL assertions.
         */
        `define LOGIC_STD_OVL_DISABLED
    `endif
`endif

`include "logic_drc.svh"
`include "logic_config.svh"
`include "logic_axi4.svh"
`include "logic_avalon.svh"
`include "logic_modport.svh"

`ifndef LOGIC_STD_OVL_DISABLED
`include "std_ovl_defines.h"
`endif

`endif /* LOGIC_SVH */
