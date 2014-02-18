require '~user/nif.ijs'

cocurrent 'writenif'
erase names''

get=: ({:@] i. ($~ $ -.1:)@;:@[) >@{ {.@]
put=: 3 :0
  0 0$WRITENIF=:WRITENIF,,y
)

write_nif=:4 :0
  assert. (-: 'Header';]&.>@i.@<:@#) {: x
  Header=. 'Header' get x
  assert. (;:'headerstring version numblocks') -: {: Header
  WRITENIF=: 'headerstring' get Header
  write_int 'version' get Header
  write_int 'numblocks' get Header
  Data=. }.{.x
  for_block. >}.{:x do.
    write_block block{::Data
  end.
  WRITENIF fwrite y
  i.0 0
)

write_block=:3 :0
  smoutput $y
)


NB. basic writers

defwr=: 2 :0
  ('write_',m)=: v
)
defWRITE=: 2 :0
  m defwr (put@v)
)

'char' defWRITE ]
'byte' defWRITE ({&a.)

ic=: 3!:4
'Flags' defWRITE (1&ic)

fc=: 3!:5
'float' defWRITE  (1&fc)
'IndexString' defWR [: NB. force an error if we get here
'int' defWRITE (2&ic)

NB. bools have a dual existence:
NB. a true/false value (a count - 0 or 1 times)
NB. a literal value (an arbitrary number)
'bool' defwr (2&ic@:({:"1))

'NiObject' defwr (''"_)
'Ptr' defwr write_int
'Ref' defwr write_int
'short' defWRITE (1&ic)
'ushort' defWRITE (1&ic)
'unsigned' defwr write_int 
'uint' defwr write_unsigned

NB. test on load
require '~user/readnif.ijs'
DATANIF_readnif_ write_nif '~user/testout.nif'