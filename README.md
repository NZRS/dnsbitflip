# dnsbitflip

DNS bit flip

A tool that generates the various DNS labels that may be accidentally 
queried through unexpected single bit flipping, such as those caused 
by cosmic rays.  Has a number of options for controlling how the 
labels are generated.

# Usage
<pre>
usage: dnsbitflip label [-u] [-8] [-c] [-d]
        
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
      strings generated as "Count: number".
      
  -d  By default duplicate generated strings are removed.  If these are 
      needed, say for frequency analysis, then this option will include them.
      Duplicates that differ only in case will all be output in lower case 
      unless -u is also specified.
</pre>      
# Examples

Using the tool for the single character label 'c' generates the following
results, depending on the options chosen:

<table>
    <thead>
        <tr>
            <td>none</td><td>-u</td><td>-8</td><td>-u -8</td><td>-d</td>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>a<br />
            b<br />
            g<br />
            k<br />
            s
            </td>
            <td>C<br />
            a<br />
            b<br />
            g<br />
            k<br />
            s
            </td>
            <td>#<br />
            a<br />
            b<br />
            g<br />
            k<br />
            s<br />
            ã
            </td>
            <td>#<br />
            C<br />
            a<br />
            b<br />
            g<br />
            k<br />
            s<br />
            ã
            </td>
            <td>a<br />
            b<br />
            c<br />
            g<br />
            k<br />
            s
            </td>
        </tr>
    </tbody>
</table>