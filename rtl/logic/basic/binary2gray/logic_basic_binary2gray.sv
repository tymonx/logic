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

/* Module: logic_basic_binary2gray
 *
 * Converts input binary data to data coded in gray codes.
 *
 * Parameters:
 *  WIDTH   - Number of bits for input and output signals.
 *
 * Ports:
 *  i           - Input binary data.
 *  o           - Output gray data.
 */
module logic_basic_binary2gray #(
    int WIDTH = 1
) (
    input [WIDTH-1:0] i,
    output logic [WIDTH-1:0] o
);
    always_comb begin
        o[WIDTH-1] = i[WIDTH-1];

        for (int k = 0; k < (WIDTH - 1); ++k) begin
            o[k] = i[k] ^ i[k + 1];
        end
    end
endmodule
