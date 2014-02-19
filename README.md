nifty
=====

J implementation of NIF file support. See also: http://niftools.sourceforge.net/wiki/About_NifTools

---------------------------------------------------------

Currently early draft

Version hardcoded to Morrowind

Files should go in obvious locations in J user directory

(Polish must wait until after functionality.)

---------------------------------------------------------

roughly patterened after http://rpmfind.net/linux/RPM/sourceforge/p/py/pyffi/OldFiles/PyFFI-0.0-1.noarch.html
you should not expect to read the part of this codebase any faster than you read the equivalent in PyFFI
and if you are new to J you should also expect to spend some time learning the language
recommendation: take breaks occasionally, play with this, try to make it fun


---------------------------------------------------------

parsed nif file currently appears as DATANIF_readnif_ and the orcish table example is automatically parsed when readnif.ijs is loaded.

Loading writenif.ijs currently generates ~user/testout.nif which is an identical copy of the original table file.

---------------------------------------------------------

Todo:

migrate testing out of main read/write implementations

render 1 nif object - needs texture support
render 2 nif objects
render 3 nif objects

print 1 nif object - neglect texture support

editing (need to define supported editing operations)

Exercise editor - do something interesting for Morrowind community

Start supporting other nif versions

