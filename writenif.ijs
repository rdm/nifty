require jcwdpath 'nifxml.ijs'

cocurrent 'writenif'
erase names''
coinsert 'nifexpr'

get=: ({:@] i. ($~ $ -.1:)@;:@[) >@{ {.@]
get=:4 :0
  WRITENIF_base_=: WRITENIF
  X_base_=: x
  Y_base_=: y
  nm=. ($~ $ -.1:)@;: x
  vals=. {. y
  ndx=. ({: y) i. nm
  assert. (#WRITENIF) -: ndx {:: 1 { y
  > ndx { vals
)

put=: 3 :0
  0 0$WRITENIF=:WRITENIF,,y
)

write_nif=:4 :0
  WRITENIF=: put_nif x
  WRITENIF fwrite y
  i.0 0
)

put_nif=:3 :0
  assert. ('Header';(<"0 i._2+{:$y),<'Footer') -: {: y
  WRITENIF=: ''
  Header=. 'Header' get y
  assert. (;:'headerstring version numblocks') -: {: Header
  write_char 'headerstring' get Header
  write_int 'version' get Header
  write_int 'numblocks' get Header
  Data=. }.{.y
  for_block. >}:}.{:y do.
    write_block block{::Data
  end.
  'Footer' build_compound
  _ write_Footer 'Footer' get y
  WRITENIF
)

write_block=:3 :0
  type=. 'type' get y
  type build_writer
  ".'''',type,''' write_',type,' y'
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
    case.            do. assert. 0-:'fail' [smoutput  m
  end.
)

build_compound=:1 :0
  'base overview detail'=. extract_nifxml_ m
  def=. '  _ write_',m,' y',LF
  def=. def,':',LF
  def=. def,'  if. 0=#y do. return. end.',LF
  if. #inherit=. ;(#~ e.&(<'inherit'))~/|:overview do.
    def=. def,'  x write_',(inherit),' y',LF
    inherit build_writer
  else.
    def=. def,'  assert. (-: ~.){:y',LF
    def=. def,'  write_string x',LF
  end.
  for_add. detail do.
    recipe=. |:1 {::,>add
    type=. ;(#~ e.&(<'type'))~/recipe
    type build_writer
    label=. ' '-.~;(#~ e.&(<'name'))~/recipe
    def=. def,'  write_',type,' ''',label,''' get y',LF
  end.
  debug  '''',m,''' defwr (3 :0)',LF,def,')',LF
  m defwr (3 :def) 
)

build_enum=:1 :0
  'base overview detail'=. extract_nifxml_ m
  writer=. 'write_',;(#~ e.&(<'storage'))~/@|: overview
  enum=. >1{&>,detail
  values=. 0".>, (#~ e.&(<'value'))~/@|:"2 enum
  names=. , (#~ e.&(<'name'))~/@|:"2 enum
  data=. names values} a:#~1+>./values
  debug  '''',m,''' defwr ((<;._2]0 :0) ',writer,'@i. ])',LF,(;data,each LF),')',LF
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
'bool' defWRITE (2&ic@:({:"1))

'Ptr' defwr write_int
'Ref' defwr write_int
'short' defWRITE (1&ic@,)
'ushort' defWRITE (1&ic@,)
'unsigned' defwr write_int 
'uint' defwr write_unsigned

NB. special case code (needed to match special case read code) -----

'SizedString' defwr (3 :0)
  if. _ -: y do. return. end.
  write_int #y
  write_char y
)
'string' defwr (write_SizedString L:0)

'NiGeometryData' defwr (3 :0)
  _ write_NiGeometryData y
:
  if. 0=#y do. return. end.
  x write_NiObject y
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
'Matrix33' defwr (write_float@|:^:(0<#))
'Matrix22' defwr (write_float@|:^:(0<#))
