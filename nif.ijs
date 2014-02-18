NB. roughly patterened after http://rpmfind.net/linux/RPM/sourceforge/p/py/pyffi/OldFiles/PyFFI-0.0-1.noarch.html
NB. you should not expect to read the part of this codebase any faster than you read the equivalent in PyFFI
NB. and if you are new to J you should also expect to spend some time learning the language
NB. recommendation: take breaks occasionally, play with this, try to make it fun

NB. nif.ijs - relatively abstract class
NB.   see also: readnif.ijs, writenif.ijs, nifxml.ijs

require '~user/nifxml.ijs'
coinsert 'nifxml' NB. for cond expressions

NB. extract crude definition from nif.xml 
process_nifxml_  fread '~user/nif.xml'


lr_z_=:3 :'5!:5 <''y'''


