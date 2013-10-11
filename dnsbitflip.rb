#!/usr/bin/ruby

# dnsbitflip
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

$arguments = ARGV.length

if $arguments == 0
  print "usage: dnsbitflip label [-u] [-8] [-c] [-d]
        
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
      unless -u is also specified.\n"
  exit(0)
end


# process the label
$source = ARGV[0].downcase
$source_len = $source.length

if $source_len > 64 
  print "Error: input label greater than 64 bytes\n"
  exit(1)
end


# process the other arguments
$arg_8 = false
$arg_u = false
$arg_c = false
$arg_d = false

if $arguments > 1
  ARGV[1, $arguments-1].each do |a|
    case a
    when "-u" 
      $arg_u = true
    when "-8"
      $arg_8 = true
    when "-c"
      $arg_c = true
    when "-d"
      $arg_d = true
    end
  end
end


BITS = $arg_8 ? [128, 64, 32, 16, 8, 4, 2, 1] : [64, 32, 16, 8, 4, 2, 1]
LDH = /[a-zA-Z0-9\-.]/

# do the work  - variables named in such a way to allow this to become a function later
results = []

(0..($source_len-1)).each do |l|
  c = $source[l]
  batch = []                # holds the strings generated from flipping just this character

  # build the two parts on either side of the character to be flipped
  lhs = l > 0 ? $source[0, l] : ""
  rhs = l < $source_len ? $source[l + 1, $source_len - l] : ""


  BITS.each do |b|                               # now go through each bit
    f = (c & b == b ? c - b : c + b).chr         # flip it
    if $arg_8 || f =~ LDH                        # check that it is an allowed character if not doing 8 bit
      f.downcase! unless $arg_u
      ps = lhs + f + rhs                         # create the bit flipped string
      batch.push(ps) if $arg_d || ps != $source   # if it isn't the same as the source then add it to the results unless told to
    end
  end
    
  batch.sort!                                   # sort the generated strings
  results.concat(batch)                         # and add them to the results
end

results.uniq! unless $arg_d    # remove duplicates unless told not to

print "Count: #{results.length}\n" if $arg_c

results.each do |r|       # print the results
  print r + "\n"
end
