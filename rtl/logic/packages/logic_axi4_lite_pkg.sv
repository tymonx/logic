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

/* Package: logic_axi4_lite_pkg
 *
 * Logic package.
 */
package logic_axi4_lite_pkg;
    /* Enum: privilege_access_t
     *
     * Privilege access.
     *
     * PRIVILEGE_ACCESS_UNPRIVILEGED    - Unprivileged access.
     * PRIVILEGE_ACCESS_PRIVILEGED      - Privileged access.
     */
    typedef enum logic [0:0] {
        PRIVILEGE_ACCESS_UNPRIVILEGED   = 1'b0,
        PRIVILEGE_ACCESS_PRIVILEGED     = 1'b1
    } privilege_access_t;

    /* Enum: security_access_t
     *
     * Security access.
     *
     * SECURITY_ACCESS_SECURE       - Secure access.
     * SECURITY_ACCESS_NON_SECURE   - Non-secure access.
     */
    typedef enum logic [0:0] {
        SECURITY_ACCESS_SECURE      = 1'b0,
        SECURITY_ACCESS_NON_SECURE  = 1'b1
    } security_access_t;

    /* Enum: type_access_t
     *
     * Type access.
     *
     * TYPE_ACCESS_DATA         - Data access.
     * TYPE_ACCESS_INSTRUCTION  - Instruction access.
     */
    typedef enum logic [0:0] {
        TYPE_ACCESS_DATA        = 1'b0,
        TYPE_ACCESS_INSTRUCTION = 1'b1
    } type_access_t;

    /* Enum: access_t
     *
     * Access.
     *
     * type_access      - Type access.
     * security_access  - Security access.
     * privilege_access - Privilege access.
     */
    typedef struct packed {
        type_access_t type_access;
        security_access_t security_access;
        privilege_access_t privilege_access;
    } access_t;

    /* Const: DEFAULT_DATA_ACCESS
     *
     * Default data access permission.
     */
    localparam access_t DEFAULT_DATA_ACCESS = '{
        type_access: TYPE_ACCESS_DATA,
        security_access: SECURITY_ACCESS_SECURE,
        privilege_access: PRIVILEGE_ACCESS_UNPRIVILEGED
    };

    /* Const: DEFAULT_INSTRUCTION_ACCESS
     *
     * Default data access permission.
     */
    localparam access_t DEFAULT_INSTRUCTION_ACCESS = '{
        type_access: TYPE_ACCESS_INSTRUCTION,
        security_access: SECURITY_ACCESS_SECURE,
        privilege_access: PRIVILEGE_ACCESS_UNPRIVILEGED
    };

    /* Enum: response_t
     *
     * Write/read response.
     *
     * RESPONSE_OKAY    - Normal access success.
     * RESPONSE_EXOKAY  - Exclusive access okay.
     * RESPONSE_SLVERR  - Slave error.
     * RESPONSE_DECERR  - Decode error.
     */
    typedef enum logic [1:0] {
        RESPONSE_OKAY       = 2'b00,
        RESPONSE_EXOKAY     = 2'b01,
        RESPONSE_SLVERR     = 2'b10,
        RESPONSE_DECERR     = 2'b11
    } response_t;
endpackage
