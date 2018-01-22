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

set broken 0

onfinish stop

onbreak {
    lassign [runStatus -full] status fullstat

    if {$status eq "error"} {
        # Unexpected error, report info and force an error exit.
        echo "Error: $fullstat"
        set broken 1
        resume
    } elseif {$status eq "break"} {
        if {[string match "user_*" $fullstat]} {
            pause
        } else {
            if {[find signals test_passed] != ""} {
                if ![exa test_passed] {
                    set broken 2
                }
            } else {
                set broken 2
            }
            resume
        }
    } else {
        resume
    }
}

log -r /*
run -all

if {$broken == 1} {
    # Unexpected condition. Exit with bad status.
    quit -force -code 3
} elseif {$broken == 2} {
    # Assertion or other break condition.
    quit -force -code 1
}

quit -force
