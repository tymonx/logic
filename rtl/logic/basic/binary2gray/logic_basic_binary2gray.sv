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

/* Module: logic_basic_gray2binary
 *
 * Parameters:
 *  WIDTH   - Number of bits for input and output signals.
 *
 * Ports:
 *  i       - Input binary data.
 *  o       - Output gray data.
 */
module logic_basic_binary2gray #(
    int WIDTH = 1
) (
    input [WIDTH-1:0] i,
    output logic [WIDTH-1:0] o
);
    generate
        if (WIDTH > 1) begin: multi
            always_comb o = i ^ {1'b0, i[WIDTH-1:1]};
        end
        else begin: single
            always_comb o = i ^ 1'b0;
        end
    endgenerate
endmodule
