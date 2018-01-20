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

#include "logic/bitstream_const_reference.hpp"

using logic::bitstream_const_reference;

bitstream_const_reference::bitstream_const_reference(
        const bitstream_reference& other) noexcept :
    m_reference{other}
{ }

bitstream_const_reference::bitstream_const_reference(const_pointer bits,
        size_type index) noexcept :
    m_reference{const_cast<bitstream_reference::pointer>(bits), index}
{ }

bitstream_const_reference::operator bool() const noexcept {
    return m_reference.operator bool();
}
