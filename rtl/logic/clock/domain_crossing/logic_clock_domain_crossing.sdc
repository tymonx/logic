# Copyright 2018 Tymoteusz Blazejczyk
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# From write to read clock domain:

set_false_path \
    -from [get_registers {*logic_clock_domain_crossing_generic_read_sync:read_sync*gray_write_synced*}] \
    -to [get_registers {*logic_clock_domain_crossing_generic_read_sync:read_sync*gray_read_synced*}]

# From read to write clock domain:

set_false_path \
    -from [get_registers {*logic_clock_domain_crossing_generic_write_sync:write_sync*gray_write_synced*}] \
    -to [get_registers {*logic_clock_domain_crossing_generic_write_sync:write_sync*gray_read_synced*}]
