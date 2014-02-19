NB. roughly patterened after http://rpmfind.net/linux/RPM/sourceforge/p/py/pyffi/OldFiles/PyFFI-0.0-1.noarch.html
NB. you should not expect to read this any faster than you read the whole of PyFFI
NB. and if you are new to J you should also expect to spend some time learning the language
NB. recommendation: take breaks occasionally, play with this, try to make it fun

require '~user/nif.ijs'

cocurrent 'readnif'
erase names''
coinsert 'nifexpr'

readinherit=:''1 :(0 :0-.LF)
  [ (_1&{:: 1:@".@, '=.', lr@(0&{::))"1@|:
)

NB. from nif file name get J array
read_nif=:3 :0
  READNIF=: fread y
  assert. _1 ~: READNIF [ 'does file exist?'
  POS=: 0
  headerstring=. 40 read_char ''
  vers=. read_int ''
  assert. vers = Version
  version=. vers
  numblocks=. read_int ''
  h=. ,.headerstring;0;'headerstring'
  h=. h,.version;40;'version'
  h=. h,.numblocks;44;'numblocks'
  DATANIF=: ,.h;0;'Header'
  for_block.i. numblocks do.
    DATANIF=: DATANIF,.(read_block block);POS;block
  end.
)

read_block=: 3 :0
  type=. read_string''
  type build_reader
  (,.".'read_',type,''''''),.~type;POS;'type'
)

build_reader=: 1 :0
  type=. m
  reader=. 'read_',type
  if. 3 = nc <reader do. reader return. end.
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
  def=. '  r=. i.3 0',LF
  if. #inherit=. ;(#~ e.&(<'inherit'))~/|:overview do.
    def=. '  readinherit r=. read_',(inherit),'''''',LF
    inherit build_reader
  end.
  for_add. detail do.
    recipe=. |:1 {::,>add
    type=. ;(#~ e.&(<'type'))~/recipe
    type build_reader
    label=. ' '-.~;(#~ e.&(<'name'))~/recipe
    arr2=. (,'*'#~0<#) fixexpr (#~ e.&(<'arr2'))~/recipe
    arr1=. ,&arr2 (,'*'#~0<#) fixexpr (#~ e.&(<'arr1'))~/recipe
    if. #cond=. fixexpr (#~ e.&(<'cond'))~/recipe do.
      def=. def,'  r=. r,.(',label,'=. (',arr1,'{.',cond,') read_',type,''''');POS;''',label,'''',LF
    else.
      arr=. ('(',')',~])^:('*'e.]) _1}.arr1
      def=. def,'  r=. r,.(',label,'=. ',arr,' read_',type,''''');POS;''',label,'''',LF
    end.
  end.
  def=. def,':',LF,'  r=. x read_',m,' Repeated ''''',LF
  smoutput '''',m,''' defRD (3 :0)',LF,def,')',LF
  m defRD (3 :def)
)

Repeated=:1 :0
  u y
:
  select. {.x
    case. 0 do. i.0
    case. 1 do. u y
    case.   do. u&> x#<y
  end.
)

build_enum=:1 :0
  'base overview detail'=. extract_nifxml_ m
  fetcher=. 'read_',;(#~ e.&(<'storage'))~/@|: overview
  enum=. >1{&>,detail
  values=. 0".>, (#~ e.&(<'value'))~/@|:"2 enum
  names=. , (#~ e.&(<'name'))~/@|:"2 enum
  data=. names values} a:#~1+>./values
  smoutput '''',m,''' defRD ((<;._2]0 :0) {~ ',fetcher,')',LF,(;data,each LF),')',LF
  m defRD (data {~ fetcher~) 
)
    

NB. ------------- primitive defs -------------------------------
NB. assumed globals:
READNIF=: '' NB. is read or mapped from file
POS=: 0      NB. marks next unread byte

defRD=: 2 :0
  ('read_',m)=: v
)

NB. readers - left argument of dyad is vector length to read

'char' defRD (3 :0)
  (POS=:POS+1) ] READNIF{~POS
:
  (POS=:POS+x) ] READNIF{~POS+i.x
)
'byte' defRD (a.i.read_char)

ic=: 3!:4
'Flags' defRD (3 :0)
  (POS=:POS+2) ] {. 0 ic READNIF {~ POS+i.2
:
  (POS=:POS+2*x) ] 0 ic READNIF {~ POS+i.2*x
)


fc=: 3!:5
'float' defRD  (3 :0)
  (POS=:POS+4) ] {. _1 fc READNIF {~ POS+i.4
:
  (POS=:POS+4*x) ] _1 fc READNIF {~ POS+i.4*x
)

'IndexString' defRD [: NB. don't ask

'int' defRD (3 :0)
  (POS=:POS+4) ] {. _2 ic READNIF {~ POS+i.4
:
  (POS=:POS+4*x) ] _2 ic READNIF {~ POS+i.4*x
)

NB. bools have a dual existence:
NB. a true/false value (a count - 0 or 1 times)
NB. a literal value (an arbitrary number)
'bool' defRD ((,"0~*)@read_int)

'NiObject' defRD ((i.3 0)"_)

'Ptr' defRD read_int

'Ref' defRD read_int

'short' defRD (3 :0)
  (POS=:POS+2) ] {. _1 ic READNIF {~ POS+i.2
:
  (POS=:POS+2*x) ] _1 ic READNIF {~ POS+i.2*x
)

'ushort' defRD (3 :0)
  (POS=:POS+2) ] {. 0 ic READNIF {~ POS+i.2
:
  (POS=:POS+2*x) ] 0 ic READNIF {~ POS+i.2*x
)

'unsigned' defRD ((2^32) | read_int) 
'uint' defRD read_unsigned

NB. special compound (or other) defs ---------------------------
'SizedString' defRD (3 :0)
  length=. read_int ''
  value=. length read_char ''
:
  NB. boxing needed to preserve length of strings
  x <@read_SizedString Repeated ''
)
'string' defRD read_SizedString

'NiGeometryData' defRD (3 :0)
  readinherit r=. read_NiObject''
  r=. r,.(NumVertices=. read_ushort'');POS;'NumVertices' NB. avoid NiPSysData bogosity
  r=. r,.(HasVertices=.  read_bool'');POS;'HasVertices'
  r=. r,.(Vertices=. (NumVertices*{.HasVertices) read_Vector3'');POS;'Vertices'
  r=. r,.(HasNormals=.  read_bool'');POS;'HasNormals'
  r=. r,.(Normals=. (NumVertices*{.HasNormals) read_Vector3'');POS;'Normals'
  r=. r,.(Center=.  read_Vector3'');POS;'Center'
  r=. r,.(Radius=.  read_float'');POS;'Radius'
  r=. r,.(HasVertexColors=.  read_bool'');POS;'HasVertexColors'
  r=. r,.(VertexColors=. (NumVertices*{.HasVertexColors) read_Color4'');POS;'VertexColors'
  r=. r,.(NumUVSets=.  read_ushort'');POS;'NumUVSets'
  r=. r,.(HasUV=.  read_bool'');POS;'HasUV'
  r=. r,.(UVSets=. (((NumUVSets bAnd 63) bOr (BSNumUVSets bAnd 1))*NumVertices) read_TexCoord'');POS;'UVSets'
:
  r=. x read_NiGeometryData Repeated ''
)

NB. names would be: u v
'TexCoord' defRD ((2 read_float ]) Repeated)

NB. autogenerated version from nif.xml
NB. fails because of name conflict on 'r'
'Color3' defRD (3 :0)
  r=. i.3 0
  r=. r,.(r=. read_float'');POS;'r'
  r=. r,.(g=. read_float'');POS;'g'
  r=. r,.(b=. read_float'');POS;'b'
:
  r=. x read_Color3 Repeated ''
)
'Color3' defRD ((3 read_float ]) Repeated)

NB. similar name conflict with r g b a
'Color4' defRD ((4 read_float ]) Repeated)

NB. efficient version
NB. labels would have been v1 v2 v3
'Triangle' defRD ((3 read_ushort ]) Repeated)


NB. efficient version
NB. labels would have been: x y z
'Vector3' defRD ((3 read_float ]) Repeated)

NB. efficient version
NB. labels would have been:
NB.    m11 m12 m13
NB.    m21 m22 m23
NB.    m31 m32 m33
'Matrix33' defRD ((3 3 |:@$ 9 read_float ]) Repeated)

NB. efficient version
NB. labels would have been:
NB.    m11 m12
NB.    m21 m22
'Matrix22' defRD ((2 2 |:@$ 4 read_float ]) Repeated)

NB. work around pythonesque warts
HasUnknown2Texture=: 0
BSNumUVSets=: 0

NB. ------------------ test on load

0 0 $ read_nif jpath '~user\furniture\unpack\Furn_OrcLC_Table01.nif'
NB. needs file from http://www.nexusmods.com/morrowind/mods/42513/
