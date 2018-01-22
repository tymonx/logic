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

/* Package: logic_avalon_mm_pkg
 *
 * Logic package.
 */
package logic_avalon_mm_pkg;
    /* Enum: response_t
     *
     * Response.
     *
     * RESPONSE_OKAY        - Successful response for a transaction.
     * RESPONSE_RESERVED    - Encoding is reserved.
     * RESPONSE_SLAVEERROR  - Error from an endpoint slave. Indicates an
     *                        unsuccessful transaction.
     * RESPONSE_DECODEERROR - Indicates attempted access to an undefined
     *                        location.
     */
    typedef enum logic [1:0] {
        RESPONSE_OKAY           = 2'b00,
        RESPONSE_RESERVED       = 2'b01,
        RESPONSE_SLAVEERROR     = 2'b10,
        RESPONSE_DECODEERROR    = 2'b11
    } response_t;
endpackage
