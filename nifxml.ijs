require 'xml/sax/x2j ~user/nifexpr.ijs strings'

NB. FIXME: to support multiple versions will need to
NB.        use an object instance of nifexpr or continually update as a singleton
cocurrent 'nifexpr'

NB. nif versioning:
vton=: (256 #. '.' 0&".;._1@, ]) ::]
Version=: vton '4.0.0.2' NB. Morrowind
UserVersion=: 0
UserVersion2=: 0

NB. utility
lr=: 3 : '5!:5 <''y'''

NB. comment out second definition to see emitted definitions from readnif/writenif
debug=: smoutput
debug=: ] 

NB. this will extract a small part of the xml from nif.xml
NB. it's not particularly fast, but it's good enough for now
NB. FIXME: parse the file "just once"
x2jclass 'nifxml'
coinsert 'nifexpr'

NIFNames=: ''
NIFMembers=: ''

extract=:3 :0
  if. 0=#NIFNames do. process_nifxml_ fread jpath '~user/nif.xml' end.
  restrictVersion&> ($~ $-.1:)NIFMembers {~ NIFNames i.;: y
:
  Version_nifexpr_=: vton ::] x
  extract y
)

'Items' x2jDefn NB. dispatch xml event handlers
  /        := post''   : NIFNames=: NIFMembers=: ''
  compound := defEnd y : x defStart y
  compound := defDoc y
  basic    := defEnd y : x defStart y
  basic    := defDoc y
  bitflags := defEnd y : x defStart y
  bitflags := defDoc y
  enum     := defEnd y : x defStart y
  enum     := defDoc y
  niobject := defEnd y : x defStart y
  niobject := defDoc y
  add      := aEnd y : x aStart y
  add      := aChr y
  option   := aEnd y : x aStart y
  option   := aChr y
)

NB. quick hack: post results from object back into class
post=:3 :0
  NIFNames_nifxml_   =: NIFNames
  NIFMembers_nifxml_ =: NIFMembers
  i.0 0
)

NB. ------- "glue" ------------------------------
defStart=:4 :0 NB. event handlers for <compound>
  Name=: atr 'name'
  Element=: y
  Attributes=: attributes x
  Doc=: ''
  Details=: i.0 1
)
defEnd=:3 :0
  NIFNames=:   NIFNames,<Name
  NIFMembers=: NIFMembers,<(cleanDoc Element);Attributes;<Details
)
defDoc=:3 :0
  Doc=: Doc,y
)
cleanDoc=:3 :0
  ,.y;;:inv~.<@dltb;._2 Doc,LF
)

validVer=:3 :0
  if. _1-: y do. 1 return.end.
  expr=. fixexpr y
  ".expr
)

restrictVersion=:3 :0
  'elem attr adds'=. y
  elem;attr;<,.(#~ goodAdds&>), adds
)

goodAdds=:3 :0
  attrs=. |: 1 {:: y
  names=. {. attrs
  vals1=: ({: attrs),<'1:1'
  valsv=. ({: attrs),<Version
  get=. {::~  names i. <
  if. Version >: vton valsv get 'ver1' do.
    if. Version <: vton valsv get 'ver2' do.
      if. validVer vals1 get 'vercond' do. 
        if. '1:1' -: vals1 get 'userver' do.
          1 return.
        end.
      end.
    end.
  end.
  0
) 

aStart=:4 :0  NB. event handlers for <add>
  Attribute=:    y;<attributes x
  Comment=: ''
)
aEnd=:3 :0
  Details=: Details,<Attribute,<Comment
)
aChr=:3 :0
  Comment=: Comment,y
)
