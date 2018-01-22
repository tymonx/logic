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

module logic_clock_domain_crossing_generic_read_sync #(
    int ADDRESS_WIDTH = 1
) (
    input write_aclk,
    input write_areset_n,
    input [ADDRESS_WIDTH-1:0] write_pointer,
    input read_aclk,
    input read_areset_n,
    output logic [ADDRESS_WIDTH-1:0] write_pointer_synced
);
    logic [ADDRESS_WIDTH-1:0] write_pointer_gray;
    logic [ADDRESS_WIDTH-1:0] write_pointer_gray_q;
    logic [ADDRESS_WIDTH-1:0] write_pointer_synced_gray_q;
    logic [ADDRESS_WIDTH-1:0] write_pointer_synced_binary;

    logic_basic_binary2gray #(
        .WIDTH(ADDRESS_WIDTH)
    )
    binary2gray (
        .i(write_pointer),
        .o(write_pointer_gray)
    );

    logic_basic_synchronizer #(
        .WIDTH(ADDRESS_WIDTH),
        .STAGES(1)
    )
    gray_write_synced (
        .aclk(write_aclk),
        .areset_n(write_areset_n),
        .i(write_pointer_gray),
        .o(write_pointer_gray_q)
    );

    logic_basic_synchronizer #(
        .WIDTH(ADDRESS_WIDTH),
        .STAGES(2)
    )
    gray_read_synced (
        .aclk(read_aclk),
        .areset_n(read_areset_n),
        .i(write_pointer_gray_q),
        .o(write_pointer_synced_gray_q)
    );

    logic_basic_gray2binary #(
        .WIDTH(ADDRESS_WIDTH)
    )
    gray2binary (
        .i(write_pointer_synced_gray_q),
        .o(write_pointer_synced_binary)
    );

    logic_basic_synchronizer #(
        .WIDTH(ADDRESS_WIDTH),
        .STAGES(1)
    )
    binary_synced (
        .aclk(read_aclk),
        .areset_n(read_areset_n),
        .i(write_pointer_synced_binary),
        .o(write_pointer_synced)
    );
endmodule
