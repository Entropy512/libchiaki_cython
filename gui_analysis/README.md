Chiaki's current header structure is not friendly to "external" users due to complete lack of separation between "internal" and "external" headers.  This is making writing a wrapper become a nightmare.

So rather than the prior attempt to convert EVERYTHING into a PXD tree, it's time to begin analyzing the Chiaki GUI and CLI source code to determine which functions and datatypes actually are used externally from libchiaki.  Fortunately, almost all functions and types in libchiaki header files are prefixed by chiaki_headerfilename

So we'll generate a list of keywords to search for from the header files, grep those in the GUI and CLI, and use that to begin migrating those things to an "external" header file for libchiaki.

```
for kw in `cat ~/gitrepos/libchiaki_cython/gui_analysis/keywords.txt`; do echo $kw; grep -r $kw gui; done > ~/gitrepos/libchiaki_cython/gui_analysis/gui_keyword_hits.txt
```