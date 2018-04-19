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

`ifndef LOGIC_SVH
`define LOGIC_SVH

`ifdef SYNTHESIS
    `ifdef OVL_ASSERT_ON
        `undef OVL_ASSERT_ON
    `endif
`elsif VERILATOR
    /* Define: SYNTHESIS
     *
     * Enable only synthesizable parts of HDL.
     */
    `define SYNTHESIS
`endif

`include "logic_drc.svh"
`include "logic_axi4.svh"
`include "logic_avalon.svh"
`include "logic_modport.svh"

`ifdef OVL_ASSERT_ON
`define OVL_VERILOG
`define OVL_SVA_INTERFACE
`include "std_ovl_defines.h"
`endif

`endif /* LOGIC_SVH */
