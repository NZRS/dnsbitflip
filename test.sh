#!/bin/bash

# test.sh
#
# A bash script to test the output of the two versions of dnsbitflip.
# Needs the file 'referenceoutput' present in the same directory
# as the two scripts.
#
# Copyright (c) 2013 New Zealand Domain Name Registry Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see {http://www.gnu.org/licenses/}.
#


echo Running tests ...

# check referenceoutput exists
if [ ! -e "referenceoutput" ]; then
	echo Error - file \'referenceoutput\' not found
	exit 1
fi

# run the two scripts for all LDH
./dnsbitflip.rb abcdefghijklmnopqrstuvwxyz0123456789.- -u -c -d -8 > t1
./dnsbitflip.py abcdefghijklmnopqrstuvwxyz0123456789.- -u -c -d -8 > t2


echo Test 1 - ruby output is correct

diff referenceoutput t1

if [ "$?" = "0" ]; then
	echo Test 1 passed
else
	echo Test 1 failed
fi



echo Test 2 - python output is correct

diff referenceoutput t2

if [ "$?" = "0" ]; then
	echo Test 2 passed
else
	echo Test 2 failed
fi




echo Test 3 - python and ruby deliver same output

diff t1 t2

if [ "$?" = "0" ]; then
	echo Test 3 passed
else
	echo Test 3 failed
fi


rm t1
rm t2

echo ... all tests completed