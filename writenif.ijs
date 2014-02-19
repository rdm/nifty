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
  type=. 'type' get y
  type build_writer
  ".'write_',type,' y'
)

build_writer=:1 :0
  type=. m
  writer=. 'write_',type
  if. 3 = nc <writer do. writer return. end.
  'base overview detail'=. extract_nifxml_ m
  select. 0{::,base
    case. 'compound' do. m build_compound
    case. 'enum'     do. m build_enum
    case. 'niobject' do. m build_compound
    case.            do. assert. 0-:'fail' [smoutput m
  end.
)

build_compound=:1 :0
  'base overview detail'=. extract_nifxml_ m
  if=. 'if. 0=#y do. return. end.',LF
  def=. if,'  assert. (-: ~.){:y',LF
  if. #inherit=. ;(#~ e.&(<'inherit'))~/|:overview do.
    def=. if,'  write_',(inherit),' y',LF
    inherit build_writer
  end.
  for_add. detail do.
    recipe=. |:1 {::,>add
    type=. ;(#~ e.&(<'type'))~/recipe
    type build_writer
    label=. ' '-.~;(#~ e.&(<'name'))~/recipe
    def=. def,'  write_',type,' ''',label,''' get y',LF
  end.
  smoutput '''',m,''' defwr (3 :0)',LF,def,')',LF
  m defwr (3 :def) 
)

build_enum=:1 :0
  'base overview detail'=. extract_nifxml_ m
  writer=. 'write_',;(#~ e.&(<'storage'))~/@|: overview
  enum=. >1{&>,detail
  values=. 0".>, (#~ e.&(<'value'))~/@|:"2 enum
  names=. , (#~ e.&(<'name'))~/@|:"2 enum
  data=. names values} a:#~1+>./values
  smoutput '''',m,''' defwr ((<;._2]0 :0) ',writer,'@i. ])',LF,(;data,each LF),')',LF
  m defwr (data writer~@i. ]) 
)

NB. basic writers ----------------------------------------------

defwr=: 2 :0
  ('write_',m)=: v
)
defWRITE=: 2 :0
  m defwr (put@v)
)

'char' defWRITE ]
'byte' defWRITE ({&a.)

ic=: 3!:4
'Flags' defWRITE (1&ic@,)

fc=: 3!:5
'float' defWRITE  (1&fc@,)
'IndexString' defWR [: NB. force an error if we get here
'int' defWRITE (2&ic@,)

NB. bools have a dual existence:
NB. a true/false value (a count - 0 or 1 times)
NB. a literal value (an arbitrary number)
'bool' defwr (2&ic@:({:"1))

'NiObject' defwr (''"_)
'Ptr' defwr write_int
'Ref' defwr write_int
'short' defWRITE (1&ic@,)
'ushort' defWRITE (1&ic@,)
'unsigned' defwr write_int 
'uint' defwr write_unsigned

NB. special case code (needed to match special case read code) -----

'SizedString' defwr (3 :0)
  write_int #y
  write_char y
)
'string' defwr (write_SizedString L:0)

'NiGeometryData' defwr (3 :0)
  write_NiObject y  
  write_ushort 'NumVertices' get y NB. avoid NiPSysData bogosity
  write_bool 'HasVertices' get y
  write_Vector3 'Vertices' get y
  write_bool 'HasNormals' get y
  write_Vector3 'Normals' get y
  write_Vector3 'Center' get y
  write_float 'Radius' get y
  write_bool 'HasVertexColors' get y
  write_Color4 'VertexColors' get y
  write_ushort 'NumUVSets' get y
  write_bool 'HasUV' get y
  write_TexCoord 'UVSets' get y
)

'TexCoord' defwr write_float
'Color3' defwr write_float
'Color4' defwr write_float
'Triangle' defwr write_ushort
'Vector3' defwr write_float
'Matrix33' defwr (write_float@|:@$~&3 3\~&_9^:(0<#))
'Matrix22' defwr (write_float@|:@$~&2 2\~&_4^:(0<#))

NB. test on load
require '~user/readnif.ijs'
DATANIF_readnif_ write_nif jpath '~user/testout.nif'