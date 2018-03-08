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

/* Package: logic_pkg
 *
 * Logic package.
 */
package logic_pkg;
    /* Enum: system_t
     *
     * System select.
     *
     * SYSTEM_GENERIC           - Generic system
     * SYSTEM_SIMULATION        - Default system targeted for simulation.
     * SYSTEM_INTEL_HPS         - Intel Hard Processor System (ARM).
     * SYSTEM_INTEL_NIOS_II     - Intel soft-processor Nios-II.
     * SYSTEM_XILINX_ZYNQ       - Xilinx hard-processor Zynq.
     * SYSTEM_XILINX_MICROBLAZE - Xilinx soft-processor MicroBlaze.
     */
    typedef enum {
        SYSTEM_GENERIC,
        SYSTEM_SIMULATION,
        SYSTEM_INTEL_HPS,
        SYSTEM_INTEL_NIOS_II,
        SYSTEM_XILINX_ZYNQ,
        SYSTEM_XILINX_MICROBLAZE
    } system_t;

    /* Enum: target_t
     *
     * Optimize project using dedicated target.
     *
     * TARGET_GENERIC            - Generic target not related to any vendor or
     *                             device.
     * TARGET_SIMULATION         - Optimized for simulation.
     * TARGET_INTEL              - Optimized for non-specific Intel FPGAs.
     * TARGET_INTEL_ARRIA_10     - Optimized for Intel Arria 10 without HPS.
     * TARGET_INTEL_ARRIA_10_SOC - Optimized for Intel Arria 10 with HPS.
     */
    typedef enum {
        TARGET_GENERIC,
        TARGET_SIMULATION,
        TARGET_INTEL,
        TARGET_INTEL_ARRIA_10,
        TARGET_INTEL_ARRIA_10_SOC
    } target_t;
endpackage
