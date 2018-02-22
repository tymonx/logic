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

`include "logic.svh"

module logic_basic_queue_generic_capacity #(
    int ADDRESS_WIDTH = 1
) (
    input aclk,
    input areset_n,
    input write_enable,
    input read_enable,
    output logic [ADDRESS_WIDTH:0] capacity
);
    always_ff @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            capacity <= '0;
        end
        else if (write_enable && !read_enable) begin
            capacity <= capacity + 1'b1;
        end
        else if (!write_enable && read_enable) begin
            capacity <= capacity - 1'b1;
        end
    end

`ifdef OVL_ASSERT_ON
    /* verilator lint_off UNUSED */
    logic [`OVL_FIRE_WIDTH-1:0] assert_capacity_overflow_fire;
    logic [`OVL_FIRE_WIDTH-1:0] assert_capacity_underflow_fire;
    /* verilator lint_on UNUSED */

    ovl_no_transition #(
        .severity_level(`OVL_FATAL),
        .width(ADDRESS_WIDTH + 1),
        .property_type(`OVL_ASSERT),
        .msg("capacity cannot overflow")
    )
    assert_capacity_overflow (
        .clock(aclk),
        .reset(areset_n),
        .enable(1'b1),
        .test_expr(capacity),
        .start_state('1),
        .next_state('0),
        .fire(assert_capacity_overflow_fire)
    );

    ovl_no_transition #(
        .severity_level(`OVL_FATAL),
        .width(ADDRESS_WIDTH + 1),
        .property_type(`OVL_ASSERT),
        .msg("capacity cannot underflow")
    )
    assert_capacity_underflow (
        .clock(aclk),
        .reset(areset_n),
        .enable(1'b1),
        .test_expr(capacity),
        .start_state('0),
        .next_state('1),
        .fire(assert_capacity_underflow_fire)
    );
`endif

endmodule
