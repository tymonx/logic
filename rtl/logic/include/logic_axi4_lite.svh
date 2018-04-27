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

`ifndef LOGIC_AXI4_LITE_SVH
`define LOGIC_AXI4_LITE_SVH

/* Define: LOGIC_AXI4_LITE_IF_ASSIGN
 *
 * Assign SystemVerilog interface to another SystemVerilog interface.
 *
 * Parameters:
 *  lhs       - SystemVerilog interface.
 *  rhs       - SystemVerilog interface.
 */
`define LOGIC_AXI4_LITE_IF_ASSIGN(lhs, rhs) \
    always_comb lhs``.awvalid = rhs``.awvalid; \
    always_comb lhs``.awaddr = rhs``.awaddr; \
    always_comb lhs``.awprot = rhs``.awprot; \
    always_comb rhs``.awready = lhs``.awready; \
    always_comb lhs``.wvalid = rhs``.wvalid; \
    always_comb lhs``.wdata = rhs``.wdata; \
    always_comb lhs``.wstrb = rhs``.wstrb; \
    always_comb rhs``.wready = lhs``.wready; \
    always_comb rhs``.bvalid = lhs``.bvalid; \
    always_comb rhs``.bresp = lhs``.bresp; \
    always_comb lhs``.bready = rhs``.bready; \
    always_comb lhs``.arvalid = rhs``.arvalid; \
    always_comb lhs``.araddr = rhs``.araddr; \
    always_comb lhs``.arprot = rhs``.arprot; \
    always_comb rhs``.arready = lhs``.arready; \
    always_comb rhs``.rvalid = lhs``.rvalid; \
    always_comb rhs``.rdata = lhs``.rdata; \
    always_comb rhs``.rresp = lhs``.rresp; \
    always_comb lhs``.rready = rhs``.rready

/* Define: LOGIC_AXI4_LITE_IF_SLAVE_ASSIGN
 *
 * Assign standalone signals to signals in SystemVerilog interface.
 *
 * Parameters:
 *  lhs       - SystemVerilog interface.
 *  rhs       - Standalone SystemVerilog signals.
 */
`define LOGIC_AXI4_LITE_IF_SLAVE_ASSIGN(lhs, rhs) \
    always_comb lhs``.awvalid = rhs``_awvalid; \
    always_comb lhs``.awaddr = rhs``_awaddr; \
    always_comb lhs``.awprot = rhs``_awprot; \
    always_comb rhs``_awready = lhs``.awready; \
    always_comb lhs``.wvalid = rhs``_wvalid; \
    always_comb lhs``.wdata = rhs``_wdata; \
    always_comb lhs``.wstrb = rhs``_wstrb; \
    always_comb rhs``_wready = lhs``.wready; \
    always_comb rhs``_bvalid = lhs``.bvalid; \
    always_comb rhs``_bresp = lhs``.bresp; \
    always_comb lhs``.bready = rhs``_bready; \
    always_comb lhs``.arvalid = rhs``_arvalid; \
    always_comb lhs``.araddr = rhs``_araddr; \
    always_comb lhs``.arprot = rhs``_arprot; \
    always_comb rhs``_arready = lhs``.arready; \
    always_comb rhs``_rvalid = lhs``.rvalid; \
    always_comb rhs``_rdata = lhs``.rdata; \
    always_comb rhs``_rresp = lhs``.rresp; \
    always_comb lhs``.rready = rhs``_rready

/* Define: LOGIC_AXI4_LITE_IF_MASTER_ASSIGN
 *
 * Assign signals in SystemVerilog interface to standalone signals.
 *
 * Parameters:
 *  lhs       - Standalone SystemVerilog signals.
 *  rhs       - SystemVerilog interface.
 */
`define LOGIC_AXI4_LITE_IF_MASTER_ASSIGN(lhs, rhs) \
    always_comb lhs``_awvalid = rhs``.awvalid; \
    always_comb lhs``_awaddr = rhs``.awaddr; \
    always_comb lhs``_awprot = rhs``.awprot; \
    always_comb rhs``.awready = lhs``_awready; \
    always_comb lhs``_wvalid = rhs``.wvalid; \
    always_comb lhs``_wdata = rhs``.wdata; \
    always_comb lhs``_wstrb = rhs``.wstrb; \
    always_comb rhs``.wready = lhs``_wready; \
    always_comb rhs``.bvalid = lhs``_bvalid; \
    always_comb rhs``.bresp = lhs``_bresp; \
    always_comb lhs``_bready = rhs``.bready; \
    always_comb lhs``_arvalid = rhs``.arvalid; \
    always_comb lhs``_araddr = rhs``.araddr; \
    always_comb lhs``_arprot = rhs``.arprot; \
    always_comb rhs``.arready = lhs``_arready; \
    always_comb rhs``.rvalid = lhs``_rvalid; \
    always_comb rhs``.rdata = lhs``_rdata; \
    always_comb rhs``.rresp = lhs``_rresp; \
    always_comb lhs``_rready = rhs``.rready

/* Define: LOGIC_AXI4_LITE_IF_SLAVE_ASSIGN_ARRAY
 *
 * Assign standalone signals to signals in SystemVerilog interface.
 *
 * Parameters:
 *  lhs       - SystemVerilog interface.
 *  rhs       - Standalone SystemVerilog signals.
 *  index     - Array index for rhs.
 */
`define LOGIC_AXI4_LITE_IF_SLAVE_ASSIGN_ARRAY(lhs, rhs, index) \
    always_comb lhs``.awvalid = rhs``_awvalid[index]; \
    always_comb lhs``.awaddr = rhs``_awaddr[index]; \
    always_comb lhs``.awprot = rhs``_awprot[index]; \
    always_comb rhs``_awready[index] = lhs``.awready; \
    always_comb lhs``.wvalid = rhs``_wvalid[index]; \
    always_comb lhs``.wdata = rhs``_wdata[index]; \
    always_comb lhs``.wstrb = rhs``_wstrb[index]; \
    always_comb rhs``_wready[index] = lhs``.wready; \
    always_comb rhs``_bvalid[index] = lhs``.bvalid; \
    always_comb rhs``_bresp[index] = lhs``.bresp; \
    always_comb lhs``.bready = rhs``_bready[index]; \
    always_comb lhs``.arvalid = rhs``_arvalid[index]; \
    always_comb lhs``.araddr = rhs``_araddr[index]; \
    always_comb lhs``.arprot = rhs``_arprot[index]; \
    always_comb rhs``_arready[index] = lhs``.arready; \
    always_comb rhs``_rvalid[index] = lhs``.rvalid; \
    always_comb rhs``_rdata[index] = lhs``.rdata; \
    always_comb rhs``_rresp[index] = lhs``.rresp; \
    always_comb lhs``.rready = rhs``_rready[index]

/* Define: LOGIC_AXI4_LITE_IF_MASTER_ASSIGN_ARRAY
 *
 * Assign signals in SystemVerilog interface to standalone signals.
 *
 * Parameters:
 *  lhs       - Standalone SystemVerilog signals.
 *  rhs       - SystemVerilog interface.
 *  index     - Array index for lhs.
 */
`define LOGIC_AXI4_LITE_IF_MASTER_ASSIGN_ARRAY(lhs, index, rhs) \
    always_comb lhs``_awvalid[index] = rhs``.awvalid; \
    always_comb lhs``_awaddr[index] = rhs``.awaddr; \
    always_comb lhs``_awprot[index] = rhs``.awprot; \
    always_comb rhs``.awready = lhs``_awready[index]; \
    always_comb lhs``_wvalid[index] = rhs``.wvalid; \
    always_comb lhs``_wdata[index] = rhs``.wdata; \
    always_comb lhs``_wstrb[index] = rhs``.wstrb; \
    always_comb rhs``.wready = lhs``_wready[index]; \
    always_comb rhs``.bvalid = lhs``_bvalid[index]; \
    always_comb rhs``.bresp = lhs``_bresp[index]; \
    always_comb lhs``_bready[index] = rhs``.bready; \
    always_comb lhs``_arvalid[index] = rhs``.arvalid; \
    always_comb lhs``_araddr[index] = rhs``.araddr; \
    always_comb lhs``_arprot[index] = rhs``.arprot; \
    always_comb rhs``.arready = lhs``_arready[index]; \
    always_comb rhs``.rvalid = lhs``_rvalid[index]; \
    always_comb rhs``.rdata = lhs``_rdata[index]; \
    always_comb rhs``.rresp = lhs``_rresp[index]; \
    always_comb lhs``_rready[index] = rhs``.rready

`endif /* LOGIC_AXI4_LITE_SVH */
