#!/usr/bin/python3

# dnsbitflip.py
#
# A tool that generates the various DNS labels that may be accidentally 
# queried through unexpected single bit flipping, such as those caused 
# by cosmic rays.  Has a number of options for controlling how the 
# labels are generated.
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

import sys
import re


arguments = len(sys.argv)
 
if arguments == 1 :
    print("""usage: dnsbitflip label [-u] [-8] [-c] [-d]
        
    dnsbitflip is used to generate a list DNS labels that a single DNS label 
    could change into as the result of a single bit being flipped

    label:
          A string not longer than 64 bytes.  This will be converted to lower 
          case and each individual byte subjected to bit flipping.

    Options:
      -u  Every lower case ASCII letter (a-z) can be changed into the upper case
          equivalent by a single bit flip.  By default bit flipped strings that 
          only differ in case are not included.  This option includes them.
        
      -8  By default only the lowest seven bits are flipped in each byte and only 
          strings that are comprised of letters, digits, hyphens and the dot 
          character are output.  With this option selected all eight bits are
          flipped and all characters can appear in the output, except upper case
          letters and so this must be used in conjunction with -u if those are 
          also required
      
      -c  If specified then the first line of output will indicate the number of
          strings generated as \"Count: number\".
      
      -d  By default duplicate generated strings are removed.  If these are 
          needed, say for frequency analysis, then this option will include them.
          Duplicates that differ only in case will all be output in lower case 
          unless -u is also specified.""")
    sys.exit(0)


# process the label      
source = sys.argv[1].lower()
sourcelen = len(source)

if sourcelen > 64 :
    print("Error: input label greater than 64 bytes")
    sys.exit(1)

    
# process the other arguments
arg_8 = False
arg_u = False
arg_c = False
arg_d = False
    
if arguments > 2 :
  for a in sys.argv[2:] : 
    if a == "-u" : 
      arg_u = True
    elif a == "-8" :
      arg_8 = True
    elif a == "-c" :
      arg_c = True
    elif a == "-d" :
      arg_d = True

BITS = [128, 64, 32, 16, 8, 4, 2, 1] if arg_8 else [64, 32, 16, 8, 4, 2, 1]
LDH = re.compile(r"[a-zA-Z0-9\-.]")


# do the work
results = []

for l in range(sourcelen) :
    c = ord(source[l])
    batch = []
    
    # build the two parts on either side of the character to be flipped
    lhs = source[0 : l]
    rhs = source[l + 1 : sourcelen]
    
    for b in BITS :
        f = chr(c - b if c & b == b else c + b)         # flip it
        
        if arg_8 or LDH.match(f) :                      # check that it is an allowed character if not doing 8 bit
          if not arg_u : f = f.lower()
          ps = lhs + f + rhs                            # create the bit flipped string
          if arg_d or ps != source : batch.append(ps)   # if it isn't the same as the source then add it to the results unless told to
        
    batch.sort()                                        # sort the generated strings
    results.extend(batch)                               # and add them to the results

if not arg_d :                                          # remove duplicates unless told not to
    checked = []
    for e in results :
        if e not in checked :
            checked.append(e)
    results = checked

if arg_c : print("Count: {}".format(len(results)))

for r in results :      # print the results
    print(r)
