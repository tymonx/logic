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

`ifndef LOGIC_DRC_SVH
`define LOGIC_DRC_SVH

`define LOGIC_DRC_STRINGIFY(x) `"x`"

`define LOGIC_DRC_EQUAL_OR_GREATER_THAN(lhs, rhs) \
    if (!(lhs >= rhs)) begin \
        $display("DRC:%m:%s:%0d: %s (%0d) %s %s (%0d)", \
            `__FILE__, `__LINE__, \
            `LOGIC_DRC_STRINGIFY(lhs), lhs, \
            "must be equal or greater than", \
            `LOGIC_DRC_STRINGIFY(rhs), rhs \
        ); \
        $finish; \
    end

`define LOGIC_DRC_NOT_SUPPORTED(value) \
    $display("DRC:%m:%s:%0d: %s (%0d) %s", \
        `__FILE__, `__LINE__, \
        `LOGIC_DRC_STRINGIFY(value), value, \
        "not supported" \
    ); \
    $finish;

`endif /* LOGIC_DRC_SVH */
