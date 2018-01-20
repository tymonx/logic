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

`ifndef LOGIC_DRC_SVH
`define LOGIC_DRC_SVH

`define LOGIC_DRC_STRINGIFY(x) `"x`"

/* Define: LOGIC_DRC_TRUE_FALSE
 *
 * Parameter must be equal 0 (false) or 1 (true). Otherwise, synthesis or
 * simulation will be stopped.
 *
 * Parameters:
 *  value       - Parameter integer type that will be checked.
 */
`define LOGIC_DRC_TRUE_FALSE(value) \
    if (!((0 == value) || (1 == value))) begin \
        /*verilator coverage_block_off*/ \
        $display("DRC:%m:%s:%0d: %s (%0d) %s", \
            `__FILE__, `__LINE__, \
            `LOGIC_DRC_STRINGIFY(value), value, \
            "must be 0 (false) or 1 (true)" \
        ); \
        $finish; \
    end

/* Define: LOGIC_DRC_RANGE
 *
 * Parameter must be in range <min, max>. Otherwise, synthesis or
 * simulation will be stopped.
 *
 * Parameters:
 *  value       - Parameter integer type that will be checked.
 *  value_min   - Minimum value. Value must be equal or greater.
 *  value_max   - Maximum value. Value must be equal or less.
 */
`define LOGIC_DRC_RANGE(value, value_min, value_max) \
    if (!((value >= value_min) && (value <= value_max))) begin \
        /*verilator coverage_block_off*/ \
        $display("DRC:%m:%s:%0d: %s (%0d) %s %s (%0d) %s %s (%0d)", \
            `__FILE__, `__LINE__, \
            `LOGIC_DRC_STRINGIFY(value), value, \
            "must be equal or greater than", \
            `LOGIC_DRC_STRINGIFY(value_min), value_min, \
            "and equal or less than", \
            `LOGIC_DRC_STRINGIFY(value_max), value_max \
        ); \
        $finish; \
    end

/* Define: LOGIC_DRC_POWER_OF_2
 *
 * Parameter must be power of 2. Otherwise, synthesis or
 * simulation will be stopped.
 *
 * Parameters:
 *  value       - Parameter integer type that will be checked.
 */
`define LOGIC_DRC_POWER_OF_2(value) \
    if (!((0 != value) && (0 == (value & (value - 1))))) begin \
        /*verilator coverage_block_off*/ \
        $display("DRC:%m:%s:%0d: %s (%0d) %s", \
            `__FILE__, `__LINE__, \
            `LOGIC_DRC_STRINGIFY(value), value, \
            "must be power of 2" \
        ); \
        $finish; \
    end

/* Define: LOGIC_DRC_NOT_SUPPORTED
 *
 * Parameter is not supported. Synthesis or simulation will be stopped.
 * Use this define in if ... else statement or case .. default statement.
 *
 * Parameters:
 *  value       - Parameter integer type that will be checked.
 */
`define LOGIC_DRC_NOT_SUPPORTED(value) \
    $display("DRC:%m:%s:%0d: %s (%0d) %s", \
        `__FILE__, `__LINE__, \
        `LOGIC_DRC_STRINGIFY(value), value, \
        "not supported" \
    ); \
    $finish;

/* Define: LOGIC_DRC_EQUAL
 *
 * Parameters must be equal. Otherwise, synthesis or simulation will be stopped.
 *
 * Parameters:
 *  lhs       - Parameter integer type that will be checked.
 *  rhs       - Parameter integer type that will be checked.
 */
`define LOGIC_DRC_EQUAL(lhs, rhs) \
    if (!(lhs == rhs)) begin /*verilator coverage_block_off*/ \
        $display("DRC:%m:%s:%0d: %s (%0d) %s %s (%0d)", \
            `__FILE__, `__LINE__, \
            `LOGIC_DRC_STRINGIFY(lhs), lhs, \
            "must be equal to", \
            `LOGIC_DRC_STRINGIFY(rhs), rhs \
        ); \
        $finish; \
    end

/* Define: LOGIC_DRC_NOT_EQUAL
 *
 * Parameters must be not equal. Otherwise, synthesis or simulation will be
 * stopped.
 *
 * Parameters:
 *  lhs       - Parameter integer type that will be checked.
 *  rhs       - Parameter integer type that will be checked.
 */
`define LOGIC_DRC_NOT_EQUAL(lhs, rhs) \
    if (!(lhs != rhs)) begin /*verilator coverage_block_off*/ \
        $display("DRC:%m:%s:%0d: %s (%0d) %s %s (%0d)", \
            `__FILE__, `__LINE__, \
            `LOGIC_DRC_STRINGIFY(lhs), lhs, \
            "must be not equal to", \
            `LOGIC_DRC_STRINGIFY(rhs), rhs \
        ); \
        $finish; \
    end

/* Define: LOGIC_DRC_EQUAL_OR_GREATER_THAN
 *
 * First parameter must be equal or greater than second parameter.
 * Otherwise, synthesis or simulation will be stopped.
 *
 * Parameters:
 *  lhs       - Parameter integer type that will be checked.
 *  rhs       - Parameter integer type that will be checked.
 */
`define LOGIC_DRC_EQUAL_OR_GREATER_THAN(lhs, rhs) \
    if (!(lhs >= rhs)) begin /*verilator coverage_block_off*/ \
        $display("DRC:%m:%s:%0d: %s (%0d) %s %s (%0d)", \
            `__FILE__, `__LINE__, \
            `LOGIC_DRC_STRINGIFY(lhs), lhs, \
            "must be equal or greater than", \
            `LOGIC_DRC_STRINGIFY(rhs), rhs \
        ); \
        $finish; \
    end

/* Define: LOGIC_DRC_EQUAL_OR_LESS_THAN
 *
 * First parameter must be equal or less than second parameter.
 * Otherwise, synthesis or simulation will be stopped.
 *
 * Parameters:
 *  lhs       - Parameter integer type that will be checked.
 *  rhs       - Parameter integer type that will be checked.
 */
`define LOGIC_DRC_EQUAL_OR_LESS_THAN(lhs, rhs) \
    if (!(lhs <= rhs)) begin /*verilator coverage_block_off*/ \
        $display("DRC:%m:%s:%0d: %s (%0d) %s %s (%0d)", \
            `__FILE__, `__LINE__, \
            `LOGIC_DRC_STRINGIFY(lhs), lhs, \
            "must be equal or less than", \
            `LOGIC_DRC_STRINGIFY(rhs), rhs \
        ); \
        $finish; \
    end

/* Define: LOGIC_DRC_GREATER_THAN
 *
 * First parameter must be greater than second parameter.
 * Otherwise, synthesis or simulation will be stopped.
 *
 * Parameters:
 *  lhs       - Parameter integer type that will be checked.
 *  rhs       - Parameter integer type that will be checked.
 */
`define LOGIC_DRC_GREATER_THAN(lhs, rhs) \
    if (!(lhs > rhs)) begin /*verilator coverage_block_off*/ \
        $display("DRC:%m:%s:%0d: %s (%0d) %s %s (%0d)", \
            `__FILE__, `__LINE__, \
            `LOGIC_DRC_STRINGIFY(lhs), lhs, \
            "must be greater than", \
            `LOGIC_DRC_STRINGIFY(rhs), rhs \
        ); \
        $finish; \
    end

/* Define: LOGIC_DRC_LESS_THAN
 *
 * First parameter must be less than second parameter.
 * Otherwise, synthesis or simulation will be stopped.
 *
 * Parameters:
 *  lhs       - Parameter integer type that will be checked.
 *  rhs       - Parameter integer type that will be checked.
 */
`define LOGIC_DRC_LESS_THAN(lhs, rhs) \
    if (!(lhs < rhs)) begin /*verilator coverage_block_off*/ \
        $display("DRC:%m:%s:%0d: %s (%0d) %s %s (%0d)", \
            `__FILE__, `__LINE__, \
            `LOGIC_DRC_STRINGIFY(lhs), lhs, \
            "must be less than", \
            `LOGIC_DRC_STRINGIFY(rhs), rhs \
        ); \
        $finish; \
    end

`endif /* LOGIC_DRC_SVH */
