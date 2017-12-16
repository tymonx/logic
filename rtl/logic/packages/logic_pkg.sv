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

/* Package: logic_pkg
 *
 * Logic package.
 */
package logic_pkg;

    /* Enum: target_t
     *
     * Optimize project using dedicated target.
     *
     * TARGET_GENERIC          - Generic target not related to any vendor or
     *                           device.
     * TARGET_INTEL            - Optimized for non-specific Intel FPGAs.
     * TARGET_INTEL_ARRIA_10   - Optimized for Intel Arria 10 without HPS.
     */
    typedef enum {
        TARGET_GENERIC,
        TARGET_INTEL,
        TARGET_INTEL_ARRIA_10
    } target_t;
endpackage
